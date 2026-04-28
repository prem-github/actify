import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/firebase_auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../services/storage_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../domain/models/app_user.dart';
import '../../domain/models/app_user_profile.dart';
import '../../domain/models/user_role.dart';
import 'auth_flow_state.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return FirebaseAuthService(ref.watch(firebaseAuthProvider));
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirebaseFirestoreService(ref.watch(firebaseFirestoreProvider));
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return FirebaseStorageService(ref.watch(firebaseStorageProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return FirebaseAuthRepository(
    authService.authStateChanges,
    () => authService.currentUser,
    authService.verifyPhoneNumber,
    authService.signInWithCredential,
    authService.signOut,
  );
});

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return FirestoreUserProfileRepository(
    ref.watch(firestoreServiceProvider).instance,
  );
});

final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final userProfileProvider = StreamProvider<AppUserProfile?>((ref) {
  final authUser = ref.watch(authStateChangesProvider).valueOrNull;
  if (authUser == null) {
    return Stream.value(null);
  }

  return ref
      .watch(userProfileRepositoryProvider)
      .watchUserProfile(authUser.uid);
});

final authFlowControllerProvider =
    NotifierProvider<AuthFlowController, AuthFlowState>(
  AuthFlowController.new,
);

final profileSetupControllerProvider =
    AsyncNotifierProvider<ProfileSetupController, void>(
  ProfileSetupController.new,
);

class AuthFlowController extends Notifier<AuthFlowState> {
  @override
  AuthFlowState build() => const AuthFlowState();

  Future<void> sendOtp(String rawPhoneNumber) async {
    final normalizedPhone = _normalizeIndianPhoneNumber(rawPhoneNumber);
    state = state.copyWith(
      isLoading: true,
      phoneNumber: normalizedPhone,
      clearError: true,
    );

    await ref.read(authRepositoryProvider).verifyPhoneNumber(
      phoneNumber: normalizedPhone,
      verificationCompleted: (credential) async {
        state = state.copyWith(isAutoVerifying: true, clearError: true);
        try {
          await ref.read(authServiceProvider).signInWithCredential(credential);
          state = state.copyWith(
            isLoading: false,
            isAutoVerifying: false,
            otpSent: false,
            verificationId: null,
            resendToken: null,
            clearError: true,
          );
        } on FirebaseAuthException catch (error) {
          state = state.copyWith(
            isLoading: false,
            isAutoVerifying: false,
            errorMessage: error.message ?? 'Auto-verification failed.',
          );
        }
      },
      verificationFailed: (exception) {
        state = state.copyWith(
          isLoading: false,
          isAutoVerifying: false,
          errorMessage: exception.message ?? 'Phone verification failed.',
        );
      },
      codeSent: (verificationId, resendToken) {
        state = state.copyWith(
          isLoading: false,
          otpSent: true,
          verificationId: verificationId,
          resendToken: resendToken,
          clearError: true,
        );
      },
      codeAutoRetrievalTimeout: (verificationId) {
        state = state.copyWith(
          isLoading: false,
          verificationId: verificationId,
        );
      },
      forceResendingToken: state.resendToken,
    );
  }

  Future<void> verifyOtp(String smsCode) async {
    final verificationId = state.verificationId;
    if (verificationId == null || verificationId.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please request an OTP first.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authRepositoryProvider).signInWithSmsCode(
            verificationId: verificationId,
            smsCode: smsCode.trim(),
          );
      state = state.copyWith(
        isLoading: false,
        otpSent: false,
        isAutoVerifying: false,
        verificationId: null,
        resendToken: null,
        clearError: true,
      );
    } on FirebaseAuthException catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.message ?? 'Invalid OTP.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  String _normalizeIndianPhoneNumber(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('91') && digits.length == 12) {
      return '+$digits';
    }

    if (digits.length == 10) {
      return '+91$digits';
    }

    if (input.trim().startsWith('+')) {
      return input.trim();
    }

    return '+$digits';
  }
}

class ProfileSetupController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> saveProfile({
    required String name,
    required UserRole role,
    String? trainerId,
  }) async {
    final authUser = ref.read(authStateChangesProvider).valueOrNull;
    if (authUser == null) {
      throw StateError('User must be signed in before saving profile.');
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(userProfileRepositoryProvider).saveUserProfile(
            userId: authUser.uid,
            name: name.trim(),
            role: role,
            trainerId: trainerId?.trim().isEmpty == true
                ? null
                : trainerId?.trim(),
          ),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
  }
}

final routerRefreshNotifierProvider = Provider<RouterRefreshNotifier>((ref) {
  final notifier = RouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(this._ref) {
    _authSubscription = _ref.listen<AsyncValue<AppUser?>>(
      authStateChangesProvider,
      (_, __) => notifyListeners(),
      fireImmediately: true,
    );
    _profileSubscription = _ref.listen<AsyncValue<AppUserProfile?>>(
      userProfileProvider,
      (_, __) => notifyListeners(),
      fireImmediately: true,
    );
  }

  final Ref _ref;
  late final ProviderSubscription<AsyncValue<AppUser?>> _authSubscription;
  late final ProviderSubscription<AsyncValue<AppUserProfile?>>
      _profileSubscription;

  bool get isLoading => _ref.read(authStateChangesProvider).isLoading;

  AppUser? get currentUser => _ref.read(authStateChangesProvider).valueOrNull;

  AppUserProfile? get currentProfile => _ref.read(userProfileProvider).valueOrNull;

  bool get isProfileLoading => _ref.read(userProfileProvider).isLoading;

  @override
  void dispose() {
    _authSubscription.close();
    _profileSubscription.close();
    super.dispose();
  }
}

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
import '../../domain/models/app_user.dart';

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
    authService.signInAnonymously,
    authService.signOut,
  );
});

final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signInAnonymously() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInAnonymously(),
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
    _subscription = _ref.listen<AsyncValue<AppUser?>>(
      authStateChangesProvider,
      (_, __) => notifyListeners(),
      fireImmediately: true,
    );
  }

  final Ref _ref;
  late final ProviderSubscription<AsyncValue<AppUser?>> _subscription;

  bool get isLoading => _ref.read(authStateChangesProvider).isLoading;

  AppUser? get currentUser => _ref.read(authStateChangesProvider).valueOrNull;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}


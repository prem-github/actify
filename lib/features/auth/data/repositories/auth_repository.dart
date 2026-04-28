import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  AppUser? get currentUser;
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential credential) verificationCompleted,
    required void Function(FirebaseAuthException exception) verificationFailed,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
    int? forceResendingToken,
  });
  Future<void> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  });
  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(
    this._authStateChanges,
    this._currentUser,
    this._verifyPhoneNumber,
    this._signInWithCredential,
    this._signOut,
  );

  final Stream<User?> Function() _authStateChanges;
  final User? Function() _currentUser;
  final Future<void> Function({
    required String phoneNumber,
    required void Function(PhoneAuthCredential credential) verificationCompleted,
    required void Function(FirebaseAuthException exception) verificationFailed,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
    int? forceResendingToken,
  }) _verifyPhoneNumber;
  final Future<UserCredential> Function(AuthCredential credential)
      _signInWithCredential;
  final Future<void> Function() _signOut;

  @override
  Stream<AppUser?> authStateChanges() {
    return _authStateChanges().map((user) {
      if (user == null) {
        return null;
      }
      return AppUser.fromFirebaseUser(user);
    });
  }

  @override
  AppUser? get currentUser {
    final user = _currentUser();
    if (user == null) {
      return null;
    }
    return AppUser.fromFirebaseUser(user);
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential credential) verificationCompleted,
    required void Function(FirebaseAuthException exception) verificationFailed,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
    int? forceResendingToken,
  }) {
    return _verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      forceResendingToken: forceResendingToken,
    );
  }

  @override
  Future<void> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _signInWithCredential(credential);
  }

  @override
  Future<void> signOut() => _signOut();
}

import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  AppUser? get currentUser;
  Future<void> signInAnonymously();
  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._authStateChanges, this._currentUser, this._signIn, this._signOut);

  final Stream<User?> Function() _authStateChanges;
  final User? Function() _currentUser;
  final Future<UserCredential> Function() _signIn;
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
  Future<void> signInAnonymously() async {
    await _signIn();
  }

  @override
  Future<void> signOut() => _signOut();
}


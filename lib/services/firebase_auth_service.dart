import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthService {
  Stream<User?> authStateChanges();
  User? get currentUser;
  Future<UserCredential> signInAnonymously();
  Future<void> signOut();
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<UserCredential> signInAnonymously() {
    return _firebaseAuth.signInAnonymously();
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();
}


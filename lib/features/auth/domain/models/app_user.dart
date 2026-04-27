import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.isAnonymous,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;

  factory AppUser.fromFirebaseUser(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
    );
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/app_user_profile.dart';
import '../../domain/models/user_role.dart';

abstract class UserProfileRepository {
  Stream<AppUserProfile?> watchUserProfile(String userId);
  Future<AppUserProfile?> fetchUserProfile(String userId);
  Future<void> saveUserProfile({
    required String userId,
    required String name,
    required UserRole role,
    String? trainerId,
  });
}

class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Stream<AppUserProfile?> watchUserProfile(String userId) {
    return _users.doc(userId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }
      return AppUserProfile.fromMap(data);
    });
  }

  @override
  Future<AppUserProfile?> fetchUserProfile(String userId) async {
    final snapshot = await _users.doc(userId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      return null;
    }
    return AppUserProfile.fromMap(data);
  }

  @override
  Future<void> saveUserProfile({
    required String userId,
    required String name,
    required UserRole role,
    String? trainerId,
  }) {
    return _users.doc(userId).set(
      {
        'userId': userId,
        'name': name,
        'role': role.value,
        'trainerId': trainerId,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}

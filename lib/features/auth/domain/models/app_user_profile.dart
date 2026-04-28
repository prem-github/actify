import 'user_role.dart';

class AppUserProfile {
  const AppUserProfile({
    required this.userId,
    required this.name,
    required this.role,
    this.trainerId,
  });

  final String userId;
  final String name;
  final UserRole role;
  final String? trainerId;

  bool get isTrainer => role == UserRole.trainer;
  bool get isClient => role == UserRole.client;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'role': role.value,
      'trainerId': trainerId,
    };
  }

  factory AppUserProfile.fromMap(Map<String, dynamic> map) {
    return AppUserProfile(
      userId: map['userId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      role: UserRole.fromValue(map['role'] as String?) ?? UserRole.client,
      trainerId: map['trainerId'] as String?,
    );
  }
}

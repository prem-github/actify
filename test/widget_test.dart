import 'package:actify/features/auth/domain/models/app_user.dart';
import 'package:actify/features/auth/domain/models/app_user_profile.dart';
import 'package:actify/features/auth/domain/models/user_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppUser stores nullable-safe Firebase user data', () {
    const user = AppUser(
      uid: 'abc123',
      email: null,
      displayName: null,
      photoUrl: null,
      isAnonymous: true,
    );

    expect(user.uid, 'abc123');
    expect(user.isAnonymous, isTrue);
    expect(user.email, isNull);
  });

  test('AppUserProfile maps trainer and client role data', () {
    final trainer = AppUserProfile.fromMap({
      'userId': 'trainer-1',
      'name': 'Coach A',
      'role': 'trainer',
      'trainerId': null,
    });

    final client = AppUserProfile.fromMap({
      'userId': 'client-1',
      'name': 'Client B',
      'role': 'client',
      'trainerId': 'trainer-1',
    });

    expect(trainer.role, UserRole.trainer);
    expect(client.role, UserRole.client);
    expect(client.trainerId, 'trainer-1');
  });
}

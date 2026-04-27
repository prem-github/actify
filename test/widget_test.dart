import 'package:actify/features/auth/domain/models/app_user.dart';
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
}


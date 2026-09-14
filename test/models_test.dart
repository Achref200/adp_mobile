import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('user exposes a display name', () {
    const user = User(
        id: '1',
        firstName: 'Amel',
        lastName: 'Ben Salem',
        email: 'a@adp.tn',
        country: 'France');
    expect(user.fullName, 'Amel Ben Salem');
  });
  test('membership states include manual validation flow', () {
    expect(MembershipStatus.values, contains(MembershipStatus.pendingReview));
    expect(MembershipStatus.values, contains(MembershipStatus.active));
  });
}

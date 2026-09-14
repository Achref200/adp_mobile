import 'package:adp_mobile/features/auth/presentation/auth_cubit.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('auth state starts unknown without a session',
      () => expect(const AuthState().status, AuthStatus.unknown));
  test('membership lifecycle contains manual review before activation', () {
    final states = MembershipStatus.values;
    expect(states.indexOf(MembershipStatus.pendingReview),
        lessThan(states.indexOf(MembershipStatus.active)));
  });
}

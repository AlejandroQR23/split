import 'package:flutter_test/flutter_test.dart';
import 'package:split/utils/auth_redirect.dart';

void main() {
  group('resolveAuthRedirect', () {
    test('sends a signed-out user on a non-auth route to sign-in', () {
      expect(
        resolveAuthRedirect(isSignedIn: false, isAuthRoute: false),
        '/sign-in',
      );
    });

    test('leaves a signed-out user on an auth route alone', () {
      expect(
        resolveAuthRedirect(isSignedIn: false, isAuthRoute: true),
        isNull,
      );
    });

    test('sends a signed-in user away from an auth route to home', () {
      expect(resolveAuthRedirect(isSignedIn: true, isAuthRoute: true), '/');
    });

    test(
      'leaves a signed-in user on an auth route alone while their Member '
      'is still being fetched',
      () {
        expect(
          resolveAuthRedirect(
            isSignedIn: true,
            isAuthRoute: true,
            isMemberLoading: true,
          ),
          isNull,
        );
      },
    );

    test('leaves a signed-in user on a non-auth route alone', () {
      expect(
        resolveAuthRedirect(isSignedIn: true, isAuthRoute: false),
        isNull,
      );
    });

    test('sends a signed-in user who still needs a name to onboarding', () {
      expect(
        resolveAuthRedirect(
          isSignedIn: true,
          isAuthRoute: false,
          needsName: true,
        ),
        '/onboarding/name',
      );
    });

    test('leaves a signed-in user who needs a name on the name route alone', () {
      expect(
        resolveAuthRedirect(
          isSignedIn: true,
          isAuthRoute: false,
          needsName: true,
          isOnboardingNameRoute: true,
        ),
        isNull,
      );
    });

    test(
      'sends a signed-in user who just set their name on to the '
      'create-first-group nudge',
      () {
        expect(
          resolveAuthRedirect(
            isSignedIn: true,
            isAuthRoute: false,
            isOnboardingNameRoute: true,
          ),
          '/onboarding/group',
        );
      },
    );
  });
}

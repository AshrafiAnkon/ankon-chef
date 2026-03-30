import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:recipe_saver_finder/main.dart';
import 'package:recipe_saver_finder/services/auth_service.dart';
import 'package:recipe_saver_finder/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

@GenerateMocks([AuthService, auth.User])
import 'widget_test.mocks.dart';

void main() {
  testWidgets('Recipe Saver app smoke test', (WidgetTester tester) async {
    final mockAuthService = MockAuthService();

    // Mock authStateChanges to return null (not logged in)
    when(
      mockAuthService.authStateChanges,
    ).thenAnswer((_) => Stream.value(null));
    when(mockAuthService.signOut()).thenAnswer((_) async {});

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
        child: const RecipeSaverApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that the login screen elements are present
    expect(find.text('Recipe Saver'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}

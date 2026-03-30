import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:recipe_saver_finder/services/recipe_service.dart';
import 'package:recipe_saver_finder/services/auth_service.dart';
import 'package:recipe_saver_finder/services/ingredient_service.dart';
import 'package:recipe_saver_finder/providers/recipe_provider.dart';
import 'package:recipe_saver_finder/providers/auth_provider.dart';
import 'package:recipe_saver_finder/providers/ingredient_provider.dart';
import 'package:recipe_saver_finder/ui/screens/create_recipe_screen.dart';
import 'package:recipe_saver_finder/models/ingredient_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

@GenerateMocks([RecipeService, AuthService, IngredientService, auth.User])
import 'create_recipe_flow_test.mocks.dart';

void main() {
  late MockRecipeService mockRecipeService;
  late MockAuthService mockAuthService;
  late MockIngredientService mockIngredientService;
  late MockUser mockUser;

  setUp(() {
    mockRecipeService = MockRecipeService();
    mockAuthService = MockAuthService();
    mockIngredientService = MockIngredientService();
    mockUser = MockUser();

    when(mockUser.uid).thenReturn('test-user-id');
    when(mockAuthService.currentUser).thenReturn(mockUser);
    when(
      mockAuthService.authStateChanges,
    ).thenAnswer((_) => Stream.value(mockUser));
    when(mockIngredientService.allIngredients).thenAnswer(
      (_) => Stream.value([
        const Ingredient(id: '1', name: 'Tomato', category: 'Vegetable'),
      ]),
    );
  });

  testWidgets('CreateRecipeScreen handles create flow', (
    WidgetTester tester,
  ) async {
    // Set a large surface size to avoid scrolling issues in tests
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer(
      overrides: [
        recipeServiceProvider.overrideWithValue(mockRecipeService),
        authServiceProvider.overrideWithValue(mockAuthService),
        ingredientServiceProvider.overrideWithValue(mockIngredientService),
        currentUserProvider.overrideWithValue(mockUser),
      ],
    );

    when(
      mockRecipeService.createRecipe(
        userId: 'test-user-id',
        name: 'Test Recipe',
        ingredientIds: const ['1'],
        instructions: 'Test Instructions',
        tags: const [],
        prepTime: anyNamed('prepTime'),
        cookTime: anyNamed('cookTime'),
        calories: anyNamed('calories'),
        ingredientQuantities: anyNamed('ingredientQuantities'),
        imageBytes: anyNamed('imageBytes'),
        imageUrl: anyNamed('imageUrl'),
        youtubeUrl: anyNamed('youtubeUrl'),
      ),
    ).thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 50));
      return 'new-recipe-id';
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: CreateRecipeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Find and fill fields
    await tester.enterText(find.byType(TextFormField).first, 'Test Recipe');
    await tester.enterText(
      find.byType(TextFormField).last,
      'Test Instructions',
    );

    // Select ingredient
    await tester.enterText(
      find.widgetWithText(TextField, 'Search Ingredients'),
      'Tom',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tomato').first);
    await tester.pumpAndSettle();

    // Find and tap Save Button
    final saveButton = find.widgetWithText(ElevatedButton, 'Create Recipe');
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pump();

    // Check loading
    expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));

    // Wait for completion
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // Verify
    verify(
      mockRecipeService.createRecipe(
        userId: 'test-user-id',
        name: 'Test Recipe',
        ingredientIds: const ['1'],
        instructions: 'Test Instructions',
        tags: const [],
        prepTime: anyNamed('prepTime'),
        cookTime: anyNamed('cookTime'),
        calories: anyNamed('calories'),
        ingredientQuantities: anyNamed('ingredientQuantities'),
        imageBytes: anyNamed('imageBytes'),
        imageUrl: anyNamed('imageUrl'),
        youtubeUrl: anyNamed('youtubeUrl'),
      ),
    ).called(1);

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:recipe_saver_finder/services/recipe_service.dart';
import 'package:recipe_saver_finder/services/auth_service.dart';
import 'package:recipe_saver_finder/services/pantry_service.dart';
import 'package:recipe_saver_finder/services/ingredient_service.dart';
import 'package:recipe_saver_finder/providers/recipe_provider.dart';
import 'package:recipe_saver_finder/providers/auth_provider.dart';
import 'package:recipe_saver_finder/providers/pantry_provider.dart';
import 'package:recipe_saver_finder/providers/ingredient_provider.dart';
import 'package:recipe_saver_finder/ui/screens/filter_recipes_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

@GenerateMocks([
  RecipeService,
  AuthService,
  PantryService,
  IngredientService,
  auth.User,
])
import 'filter_recipes_screen_test.mocks.dart';

void main() {
  late MockRecipeService mockRecipeService;
  late MockAuthService mockAuthService;
  late MockPantryService mockPantryService;
  late MockIngredientService mockIngredientService;
  late MockUser mockUser;

  setUp(() {
    mockRecipeService = MockRecipeService();
    mockAuthService = MockAuthService();
    mockPantryService = MockPantryService();
    mockIngredientService = MockIngredientService();
    mockUser = MockUser();

    when(mockUser.uid).thenReturn('test-user-id');
    when(mockAuthService.currentUser).thenReturn(mockUser);
  });

  group('FilterRecipesScreen Widget Tests', () {
    testWidgets('renders FilterRecipesScreen without errors', (
      WidgetTester tester,
    ) async {
      // Arrange - Set up minimal mocks
      when(
        mockAuthService.authStateChanges,
      ).thenAnswer((_) => Stream.value(mockUser));
      when(
        mockRecipeService.getRecipes('test-user-id'),
      ).thenAnswer((_) => Stream.value([]));
      when(
        mockPantryService.getPantryItems('test-user-id'),
      ).thenAnswer((_) => Stream.value([]));
      when(
        mockIngredientService.allIngredients,
      ).thenAnswer((_) => Stream.value([]));

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          currentUserProvider.overrideWithValue(mockUser),
          recipeServiceProvider.overrideWithValue(mockRecipeService),
          pantryServiceProvider.overrideWithValue(mockPantryService),
          ingredientServiceProvider.overrideWithValue(mockIngredientService),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: FilterRecipesScreen()),
        ),
      );

      // Wait a bit for initial build
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - Verify app bar exists
      expect(find.text('Filter Recipes'), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('shows filter drawer when menu is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        mockAuthService.authStateChanges,
      ).thenAnswer((_) => Stream.value(mockUser));
      when(
        mockRecipeService.getRecipes('test-user-id'),
      ).thenAnswer((_) => Stream.value([]));
      when(
        mockPantryService.getPantryItems('test-user-id'),
      ).thenAnswer((_) => Stream.value([]));
      when(
        mockIngredientService.allIngredients,
      ).thenAnswer((_) => Stream.value([]));

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          currentUserProvider.overrideWithValue(mockUser),
          recipeServiceProvider.overrideWithValue(mockRecipeService),
          pantryServiceProvider.overrideWithValue(mockPantryService),
          ingredientServiceProvider.overrideWithValue(mockIngredientService),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: FilterRecipesScreen()),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      // Act - Open the drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump(const Duration(milliseconds: 300));

      // Assert - Filter options should be visible
      expect(find.text('Filter Options'), findsOneWidget);
      expect(find.text('Pantry Ingredients Only'), findsOneWidget);
      expect(find.text('Filter by Choice'), findsOneWidget);
    });
  });
}

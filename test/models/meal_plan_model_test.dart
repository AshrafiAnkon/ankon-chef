import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_saver_finder/models/meal_plan_model.dart';

void main() {
  group('MealPlan Model Tests', () {
    test('MealPlan creation', () {
      final now = DateTime.now();
      final planDate = DateTime(2025, 1, 15);

      final mealPlan = MealPlan(
        id: 'plan1',
        userId: 'user1',
        planDate: planDate,
        recipeIds: const ['recipe1', 'recipe2', 'recipe3'],
        createdAt: now,
      );

      expect(mealPlan.id, 'plan1');
      expect(mealPlan.recipeIds.length, 3);
      expect(mealPlan.planDate, planDate);
    });

    test('MealPlan copyWith adds recipes', () {
      final now = DateTime.now();
      final original = MealPlan(
        id: 'plan1',
        userId: 'user1',
        planDate: now,
        recipeIds: const ['recipe1'],
        createdAt: now,
      );

      final updated = original.copyWith(recipeIds: ['recipe1', 'recipe2']);

      expect(updated.recipeIds.length, 2);
      expect(updated.id, original.id);
    });
  });

  group('GroceryItem Model Tests', () {
    test('GroceryItem creation', () {
      const item = GroceryItem(
        ingredientId: 'ing1',
        ingredientName: 'Tomato',
        isAvailable: false,
      );

      expect(item.ingredientId, 'ing1');
      expect(item.ingredientName, 'Tomato');
      expect(item.isAvailable, false);
    });

    test('GroceryItem equality', () {
      const item1 = GroceryItem(
        ingredientId: 'ing1',
        ingredientName: 'Tomato',
        isAvailable: true,
      );

      const item2 = GroceryItem(
        ingredientId: 'ing1',
        ingredientName: 'Tomato',
        isAvailable: true,
      );

      expect(item1, equals(item2));
    });
  });
}

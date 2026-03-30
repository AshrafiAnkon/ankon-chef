import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_saver_finder/models/ingredient_model.dart';

void main() {
  group('Ingredient Model Tests', () {
    test('Ingredient creation', () {
      const ingredient = Ingredient(
        id: 'ing1',
        name: 'Tomato',
        category: 'Vegetables',
      );

      expect(ingredient.id, 'ing1');
      expect(ingredient.name, 'Tomato');
      expect(ingredient.category, 'Vegetables');
    });

    test('Ingredient equality', () {
      const ing1 = Ingredient(
        id: 'ing1',
        name: 'Tomato',
        category: 'Vegetables',
      );

      const ing2 = Ingredient(
        id: 'ing1',
        name: 'Tomato',
        category: 'Vegetables',
      );

      expect(ing1, equals(ing2));
    });
  });

  group('UserIngredient Model Tests', () {
    test('UserIngredient creation', () {
      final now = DateTime.now();
      final userIng = UserIngredient(
        userId: 'user1',
        ingredientId: 'ing1',
        isCurrent: true,
        updatedAt: now,
      );

      expect(userIng.userId, 'user1');
      expect(userIng.ingredientId, 'ing1');
      expect(userIng.isCurrent, true);
    });

    test('UserIngredient copyWith updates status', () {
      final now = DateTime.now();
      final original = UserIngredient(
        userId: 'user1',
        ingredientId: 'ing1',
        isCurrent: false,
        updatedAt: now,
      );

      final updated = original.copyWith(isCurrent: true);

      expect(updated.isCurrent, true);
      expect(updated.userId, original.userId);
    });
  });
}

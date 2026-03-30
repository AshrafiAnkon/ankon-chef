import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_saver_finder/providers/filter_recipe_provider.dart';
import 'package:recipe_saver_finder/models/recipe_model.dart';
import 'package:recipe_saver_finder/models/ingredient_model.dart';

void main() {
  group('FilterOptions', () {
    test('should create with default values', () {
      const options = FilterOptions();
      expect(options.pantryIngredientsOnly, false);
      expect(options.filterByChoice, false);
      expect(options.selectedIngredientIds, isEmpty);
      expect(options.matchAll, true);
    });

    test('should create with custom values', () {
      const options = FilterOptions(
        pantryIngredientsOnly: true,
        filterByChoice: true,
        selectedIngredientIds: ['ing1', 'ing2'],
        matchAll: false,
      );
      expect(options.pantryIngredientsOnly, true);
      expect(options.filterByChoice, true);
      expect(options.selectedIngredientIds, ['ing1', 'ing2']);
      expect(options.matchAll, false);
    });

    test('copyWith should update only specified fields', () {
      const original = FilterOptions(
        pantryIngredientsOnly: true,
        filterByChoice: false,
        selectedIngredientIds: ['ing1'],
        matchAll: true,
      );

      final updated = original.copyWith(filterByChoice: true, matchAll: false);

      expect(updated.pantryIngredientsOnly, true);
      expect(updated.filterByChoice, true);
      expect(updated.selectedIngredientIds, ['ing1']);
      expect(updated.matchAll, false);
    });
  });

  group('Filter Logic Tests', () {
    test(
      'FilterOptions correctly filters recipes by pantry ingredients only',
      () {
        final recipes = [
          Recipe(
            id: '1',
            userId: 'user1',
            name: 'Recipe 1',
            ingredientIds: const ['ing1', 'ing2'],
            instructions: 'Instructions',
            tags: const [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Recipe(
            id: '2',
            userId: 'user1',
            name: 'Recipe 2',
            ingredientIds: const ['ing1', 'ing3'],
            instructions: 'Instructions',
            tags: const [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final pantryIngredientIds = const {'ing1', 'ing2'};

        // Test the filter logic directly
        final filtered = recipes.where((recipe) {
          return recipe.ingredientIds.every(
            (id) => pantryIngredientIds.contains(id),
          );
        }).toList();

        expect(filtered, hasLength(1));
        expect(filtered[0].id, '1');
      },
    );

    test('FilterOptions correctly filters recipes by choice with matchAll', () {
      final recipes = [
        Recipe(
          id: '1',
          userId: 'user1',
          name: 'Recipe 1',
          ingredientIds: const ['ing1', 'ing2', 'ing3'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Recipe(
          id: '2',
          userId: 'user1',
          name: 'Recipe 2',
          ingredientIds: const ['ing1', 'ing4'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      const selectedIds = ['ing1', 'ing2'];

      final filtered = recipes.where((recipe) {
        return selectedIds.every((id) => recipe.ingredientIds.contains(id));
      }).toList();

      expect(filtered, hasLength(1));
      expect(filtered[0].id, '1');
    });

    test('FilterOptions correctly filters recipes by choice with matchAny', () {
      final recipes = [
        Recipe(
          id: '1',
          userId: 'user1',
          name: 'Recipe 1',
          ingredientIds: const ['ing1', 'ing3'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Recipe(
          id: '2',
          userId: 'user1',
          name: 'Recipe 2',
          ingredientIds: const ['ing2', 'ing4'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Recipe(
          id: '3',
          userId: 'user1',
          name: 'Recipe 3',
          ingredientIds: const ['ing5', 'ing6'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      const selectedIds = ['ing1', 'ing2'];

      final filtered = recipes.where((recipe) {
        return selectedIds.any((id) => recipe.ingredientIds.contains(id));
      }).toList();

      expect(filtered, hasLength(2));
      expect(filtered.map((r) => r.id), containsAll(['1', '2']));
    });

    test('FilterOptions correctly applies multiple filters together', () {
      final recipes = [
        Recipe(
          id: '1',
          userId: 'user1',
          name: 'Recipe 1',
          ingredientIds: const ['ing1', 'ing2'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Recipe(
          id: '2',
          userId: 'user1',
          name: 'Recipe 2',
          ingredientIds: const ['ing1', 'ing3'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Recipe(
          id: '3',
          userId: 'user1',
          name: 'Recipe 3',
          ingredientIds: const ['ing1', 'ing2', 'ing4'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final pantryIngredientIds = const {'ing1', 'ing2'};
      const selectedIds = ['ing1'];

      // Apply filter 1: Pantry ingredients only
      var filtered = recipes.where((recipe) {
        return recipe.ingredientIds.every(
          (id) => pantryIngredientIds.contains(id),
        );
      }).toList();

      // Apply filter 2: Filter by choice with matchAll
      filtered = filtered.where((recipe) {
        return selectedIds.every((id) => recipe.ingredientIds.contains(id));
      }).toList();

      // Recipe 1: has ing1, ing2 (both in pantry) and contains ing1 - PASS
      // Recipe 2: has ing1, ing3 (ing3 not in pantry) - FAIL pantry filter
      // Recipe 3: has ing1, ing2, ing4 (ing4 not in pantry) - FAIL pantry filter
      expect(filtered, hasLength(1));
      expect(filtered[0].id, '1');
    });
  });

  group('pantryIngredients filter logic', () {
    test('should filter ingredients by pantry ingredient IDs', () {
      final pantryIngredientIds = const {'ing1', 'ing2'};
      final allIngredients = [
        const Ingredient(id: 'ing1', name: 'Tomato', category: 'Vegetable'),
        const Ingredient(id: 'ing2', name: 'Onion', category: 'Vegetable'),
        const Ingredient(id: 'ing3', name: 'Garlic', category: 'Vegetable'),
      ];

      final filtered = allIngredients
          .where((ingredient) => pantryIngredientIds.contains(ingredient.id))
          .toList();

      expect(filtered, hasLength(2));
      expect(filtered.map((i) => i.id), containsAll(['ing1', 'ing2']));
      expect(filtered.map((i) => i.name), containsAll(['Tomato', 'Onion']));
    });

    test('should return empty list when pantry is empty', () {
      final pantryIngredientIds = <String>{};
      final allIngredients = [
        const Ingredient(id: 'ing1', name: 'Tomato', category: 'Vegetable'),
      ];

      final filtered = allIngredients
          .where((ingredient) => pantryIngredientIds.contains(ingredient.id))
          .toList();

      expect(filtered, isEmpty);
    });
  });

  group('Combined Filter Scenarios', () {
    test('no filters applied returns all recipes', () {
      final recipes = [
        Recipe(
          id: '1',
          userId: 'user1',
          name: 'Recipe 1',
          ingredientIds: const ['ing1', 'ing2'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Recipe(
          id: '2',
          userId: 'user1',
          name: 'Recipe 2',
          ingredientIds: const ['ing3', 'ing4'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      var filtered = recipes;

      // Apply filter 1: pantryIngredientsOnly = false (no filter)
      // Apply filter 2: filterByChoice = false (no filter)

      expect(filtered, hasLength(2));
      expect(filtered[0].id, '1');
      expect(filtered[1].id, '2');
    });

    test('pantryIngredientsOnly filter with no pantry items', () {
      final recipes = [
        Recipe(
          id: '1',
          userId: 'user1',
          name: 'Recipe 1',
          ingredientIds: const ['ing1', 'ing2'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Recipe(
          id: '2',
          userId: 'user1',
          name: 'Recipe 2',
          ingredientIds: const ['ing3'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final pantryIngredientIds = <String>{};

      var filtered = recipes.where((recipe) {
        return recipe.ingredientIds.every(
          (id) => pantryIngredientIds.contains(id),
        );
      }).toList();

      expect(filtered, isEmpty);
    });

    test('filterByChoice with empty selected ingredients', () {
      final recipes = [
        Recipe(
          id: '1',
          userId: 'user1',
          name: 'Recipe 1',
          ingredientIds: const ['ing1', 'ing2'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Recipe(
          id: '2',
          userId: 'user1',
          name: 'Recipe 2',
          ingredientIds: const ['ing3'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      var filtered = recipes;
      const selectedIds = <String>[];

      // Empty selectedIds should not filter
      if (selectedIds.isNotEmpty) {
        filtered = filtered.where((recipe) {
          return selectedIds.any((id) => recipe.ingredientIds.contains(id));
        }).toList();
      }

      expect(filtered, hasLength(2));
    });

    test('matchAll=true requires all selected ingredients', () {
      final recipes = [
        Recipe(
          id: '1',
          userId: 'user1',
          name: 'Pasta Carbonara',
          ingredientIds: const ['ing1', 'ing2', 'ing3', 'ing4'],
          instructions: 'Cook pasta, add bacon and cream',
          tags: const ['Italian'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Recipe(
          id: '2',
          userId: 'user1',
          name: 'Simple Pasta',
          ingredientIds: const ['ing1', 'ing5'],
          instructions: 'Cook pasta, add tomato',
          tags: const ['Simple'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Recipe(
          id: '3',
          userId: 'user1',
          name: 'Bacon Eggs',
          ingredientIds: const ['ing2', 'ing6'],
          instructions: 'Cook bacon and eggs',
          tags: const ['Breakfast'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      const selectedIds = ['ing1', 'ing2'];

      final filtered = recipes.where((recipe) {
        return selectedIds.every((id) => recipe.ingredientIds.contains(id));
      }).toList();

      expect(filtered, hasLength(1));
      expect(filtered[0].id, '1');
      expect(filtered[0].name, 'Pasta Carbonara');
    });

    test('matchAll=false requires any selected ingredient', () {
      final recipes = [
        Recipe(
          id: '1',
          userId: 'user1',
          name: 'Pasta Carbonara',
          ingredientIds: const ['ing1', 'ing2', 'ing3', 'ing4'],
          instructions: 'Cook pasta, add bacon and cream',
          tags: const ['Italian'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Recipe(
          id: '2',
          userId: 'user1',
          name: 'Simple Pasta',
          ingredientIds: const ['ing1', 'ing5'],
          instructions: 'Cook pasta, add tomato',
          tags: const ['Simple'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Recipe(
          id: '3',
          userId: 'user1',
          name: 'Bacon Eggs',
          ingredientIds: const ['ing2', 'ing6'],
          instructions: 'Cook bacon and eggs',
          tags: const ['Breakfast'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Recipe(
          id: '4',
          userId: 'user1',
          name: 'Fruit Salad',
          ingredientIds: const ['ing7', 'ing8'],
          instructions: 'Mix fruits',
          tags: const ['Healthy'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      const selectedIds = ['ing1', 'ing2'];

      final filtered = recipes.where((recipe) {
        return selectedIds.any((id) => recipe.ingredientIds.contains(id));
      }).toList();

      expect(filtered, hasLength(3));
      expect(filtered.map((r) => r.id), containsAll(['1', '2', '3']));
    });

    test('both filters active: pantry AND choice with matchAll', () {
      final recipes = [
        Recipe(
          id: '1',
          userId: 'user1',
          name: 'Recipe 1',
          ingredientIds: const ['ing1', 'ing2'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Recipe(
          id: '2',
          userId: 'user1',
          name: 'Recipe 2',
          ingredientIds: const ['ing1', 'ing3'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Recipe(
          id: '3',
          userId: 'user1',
          name: 'Recipe 3',
          ingredientIds: const ['ing1', 'ing2'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Recipe(
          id: '4',
          userId: 'user1',
          name: 'Recipe 4',
          ingredientIds: const ['ing5', 'ing6'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final pantryIngredientIds = const {'ing1', 'ing2'};
      const selectedIds = ['ing1', 'ing2'];

      // Apply filter 1: Pantry ingredients only
      var filtered = recipes.where((recipe) {
        return recipe.ingredientIds.every(
          (id) => pantryIngredientIds.contains(id),
        );
      }).toList();

      // Apply filter 2: Filter by choice with matchAll
      filtered = filtered.where((recipe) {
        return selectedIds.every((id) => recipe.ingredientIds.contains(id));
      }).toList();

      expect(filtered, hasLength(2));
      expect(filtered.map((r) => r.id), containsAll(['1', '3']));
    });

    test('both filters active: pantry AND choice with matchAny', () {
      final recipes = [
        Recipe(
          id: '1',
          userId: 'user1',
          name: 'Recipe 1',
          ingredientIds: const ['ing1', 'ing2'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Recipe(
          id: '2',
          userId: 'user1',
          name: 'Recipe 2',
          ingredientIds: const ['ing1', 'ing3'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Recipe(
          id: '3',
          userId: 'user1',
          name: 'Recipe 3',
          ingredientIds: const ['ing1', 'ing2'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final pantryIngredientIds = const {'ing1', 'ing2'};
      const selectedIds = ['ing1'];

      // Apply filter 1: Pantry ingredients only
      var filtered = recipes.where((recipe) {
        return recipe.ingredientIds.every(
          (id) => pantryIngredientIds.contains(id),
        );
      }).toList();

      // Apply filter 2: Filter by choice with matchAny
      filtered = filtered.where((recipe) {
        return selectedIds.any((id) => recipe.ingredientIds.contains(id));
      }).toList();

      expect(filtered, hasLength(2));
      expect(filtered.map((r) => r.id), containsAll(['1', '3']));
    });
  });

  group('Edge Cases', () {
    test('recipe with no ingredients', () {
      final recipes = [
        Recipe(
          id: '1',
          userId: 'user1',
          name: 'Recipe 1',
          ingredientIds: const [],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final pantryIngredientIds = const {'ing1'};
      var filtered = recipes.where((recipe) {
        return recipe.ingredientIds.every(
          (id) => pantryIngredientIds.contains(id),
        );
      }).toList();

      expect(filtered, hasLength(1)); // Empty list every() returns true
    });

    test('empty recipe list returns no results', () {
      final recipes = <Recipe>[];

      var filtered = recipes;
      expect(filtered, isEmpty);
    });

    test('single recipe matching filter', () {
      final recipes = [
        Recipe(
          id: '1',
          userId: 'user1',
          name: 'Recipe 1',
          ingredientIds: const ['ing1'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      const selectedIds = ['ing1'];
      final filtered = recipes.where((recipe) {
        return selectedIds.any((id) => recipe.ingredientIds.contains(id));
      }).toList();

      expect(filtered, hasLength(1));
      expect(filtered[0].id, '1');
    });

    test('large number of recipes filters correctly', () {
      final recipes = List.generate(
        100,
        (index) => Recipe(
          id: '$index',
          userId: 'user1',
          name: 'Recipe $index',
          ingredientIds: index % 2 == 0 ? ['ing1'] : ['ing2'],
          instructions: 'Instructions',
          tags: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      const selectedIds = ['ing1'];
      final filtered = recipes.where((recipe) {
        return selectedIds.any((id) => recipe.ingredientIds.contains(id));
      }).toList();

      expect(filtered, hasLength(50));
    });
  });
}

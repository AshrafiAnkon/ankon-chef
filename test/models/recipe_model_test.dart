import 'package:flutter_test/flutter_test.dart';

import 'package:recipe_saver_finder/models/recipe_model.dart';

void main() {
  group('Recipe Model Tests', () {
    test('Recipe creation with all fields', () {
      final now = DateTime.now();
      final recipe = Recipe(
        id: '123',
        userId: 'user1',
        name: 'Test Recipe',
        ingredientIds: const ['ing1', 'ing2'],
        instructions: 'Test instructions',
        imageUrl: 'https://example.com/image.jpg',
        tags: const ['tag1', 'tag2'],
        createdAt: now,
        updatedAt: now,
      );

      expect(recipe.id, '123');
      expect(recipe.name, 'Test Recipe');
      expect(recipe.ingredientIds.length, 2);
      expect(recipe.tags.length, 2);
    });

    test('Recipe equality with Equatable', () {
      final now = DateTime.now();
      final recipe1 = Recipe(
        id: '123',
        userId: 'user1',
        name: 'Test',
        ingredientIds: const ['ing1'],
        instructions: 'Instructions',
        tags: const [],
        createdAt: now,
        updatedAt: now,
      );

      final recipe2 = Recipe(
        id: '123',
        userId: 'user1',
        name: 'Test',
        ingredientIds: const ['ing1'],
        instructions: 'Instructions',
        tags: const [],
        createdAt: now,
        updatedAt: now,
      );

      expect(recipe1, equals(recipe2));
    });

    test('Recipe copyWith creates new instance', () {
      final now = DateTime.now();
      final original = Recipe(
        id: '123',
        userId: 'user1',
        name: 'Original',
        ingredientIds: const ['ing1'],
        instructions: 'Instructions',
        tags: const [],
        createdAt: now,
        updatedAt: now,
      );

      final updated = original.copyWith(name: 'Updated');

      expect(updated.name, 'Updated');
      expect(updated.id, original.id);
      expect(updated != original, true);
    });

    test('Recipe toFirestore creates correct map', () {
      final now = DateTime.now();
      final recipe = Recipe(
        id: '123',
        userId: 'user1',
        name: 'Test',
        ingredientIds: const ['ing1', 'ing2'],
        instructions: 'Instructions',
        imageUrl: 'https://example.com/img.jpg',
        tags: const ['tag1'],
        createdAt: now,
        updatedAt: now,
      );

      final map = recipe.toFirestore();

      expect(map['userId'], 'user1');
      expect(map['name'], 'Test');
      expect(map['ingredientIds'], ['ing1', 'ing2']);
      expect(map['imageUrl'], 'https://example.com/img.jpg');
      expect(map['tags'], ['tag1']);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_saver_finder/models/pantry_item_model.dart';

void main() {
  group('PantryItem Model Tests', () {
    test('PantryItem creation', () {
      final now = DateTime.now();
      final item = PantryItem(
        id: '123',
        userId: 'user1',
        ingredientId: 'ing1',
        amount: 2.5,
        unit: 'kg',
        addedDate: now,
        expiryDate: now.add(const Duration(days: 7)),
      );

      expect(item.id, '123');
      expect(item.amount, 2.5);
      expect(item.unit, 'kg');
    });

    test('isExpiringSoon returns true for items expiring in 3 days', () {
      final now = DateTime.now();
      final item = PantryItem(
        id: '123',
        userId: 'user1',
        ingredientId: 'ing1',
        amount: 1.0,
        unit: 'kg',
        addedDate: now,
        expiryDate: now.add(const Duration(days: 2)),
      );

      expect(item.isExpiringSoon, true);
    });

    test(
      'isExpiringSoon returns false for items expiring in more than 3 days',
      () {
        final now = DateTime.now();
        final item = PantryItem(
          id: '123',
          userId: 'user1',
          ingredientId: 'ing1',
          amount: 1.0,
          unit: 'kg',
          addedDate: now,
          expiryDate: now.add(const Duration(days: 7)),
        );

        expect(item.isExpiringSoon, false);
      },
    );

    test('isExpired returns true for expired items', () {
      final now = DateTime.now();
      final item = PantryItem(
        id: '123',
        userId: 'user1',
        ingredientId: 'ing1',
        amount: 1.0,
        unit: 'kg',
        addedDate: now.subtract(const Duration(days: 10)),
        expiryDate: now.subtract(const Duration(days: 1)),
      );

      expect(item.isExpired, true);
    });

    test('isExpired returns false for non-expired items', () {
      final now = DateTime.now();
      final item = PantryItem(
        id: '123',
        userId: 'user1',
        ingredientId: 'ing1',
        amount: 1.0,
        unit: 'kg',
        addedDate: now,
        expiryDate: now.add(const Duration(days: 5)),
      );

      expect(item.isExpired, false);
    });

    test('PantryItem with no expiry date', () {
      final now = DateTime.now();
      final item = PantryItem(
        id: '123',
        userId: 'user1',
        ingredientId: 'ing1',
        amount: 1.0,
        unit: 'kg',
        addedDate: now,
      );

      expect(item.expiryDate, null);
      expect(item.isExpired, false);
      expect(item.isExpiringSoon, false);
    });

    test('PantryItem copyWith updates fields correctly', () {
      final now = DateTime.now();
      final original = PantryItem(
        id: '123',
        userId: 'user1',
        ingredientId: 'ing1',
        amount: 1.0,
        unit: 'kg',
        addedDate: now,
      );

      final updated = original.copyWith(amount: 2.5, unit: 'L');

      expect(updated.amount, 2.5);
      expect(updated.unit, 'L');
      expect(updated.id, original.id);
    });
  });
}

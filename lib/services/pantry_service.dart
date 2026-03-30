import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pantry_item_model.dart';

/// Service for managing pantry items
class PantryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all pantry items for a user
  Stream<List<PantryItem>> getPantryItems(String userId) {
    return _firestore
        .collection('pantryItems')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => PantryItem.fromFirestore(doc))
              .toList();
          // Sort locally to avoid needing a composite index
          items.sort((a, b) => b.addedDate.compareTo(a.addedDate));
          return items;
        });
  }

  /// Get expiring pantry items (within 3 days)
  Stream<List<PantryItem>> getExpiringItems(String userId) {
    return getPantryItems(userId).map((items) {
      return items.where((item) => item.isExpiringSoon).toList();
    });
  }

  /// Get expired pantry items
  Stream<List<PantryItem>> getExpiredItems(String userId) {
    return getPantryItems(userId).map((items) {
      return items.where((item) => item.isExpired).toList();
    });
  }

  /// Add a pantry item
  Future<void> addPantryItem({
    required String userId,
    required String ingredientId,
    required double amount,
    required String unit,
    DateTime? expiryDate,
  }) async {
    final pantryItem = PantryItem(
      id: '',
      userId: userId,
      ingredientId: ingredientId,
      amount: amount,
      unit: unit,
      addedDate: DateTime.now(),
      expiryDate: expiryDate,
    );

    await _firestore.collection('pantryItems').add(pantryItem.toFirestore());
  }

  /// Update a pantry item
  Future<void> updatePantryItem({
    required String pantryItemId,
    double? amount,
    String? unit,
    DateTime? expiryDate,
  }) async {
    final updates = <String, dynamic>{};

    if (amount != null) updates['amount'] = amount;
    if (unit != null) updates['unit'] = unit;
    if (expiryDate != null) {
      updates['expiryDate'] = Timestamp.fromDate(expiryDate);
    }

    if (updates.isNotEmpty) {
      await _firestore
          .collection('pantryItems')
          .doc(pantryItemId)
          .update(updates);
    }
  }

  /// Delete a pantry item
  Future<void> deletePantryItem(String pantryItemId) async {
    await _firestore.collection('pantryItems').doc(pantryItemId).delete();
  }

  /// Get pantry item by ingredient ID
  Future<PantryItem?> getPantryItemByIngredient(
    String userId,
    String ingredientId,
  ) async {
    final snapshot = await _firestore
        .collection('pantryItems')
        .where('userId', isEqualTo: userId)
        .where('ingredientId', isEqualTo: ingredientId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return PantryItem.fromFirestore(snapshot.docs.first);
    }
    return null;
  }
}

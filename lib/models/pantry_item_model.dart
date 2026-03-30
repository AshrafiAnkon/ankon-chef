import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Pantry item model for tracking ingredients with amounts and expiry dates
class PantryItem extends Equatable {
  final String id;
  final String userId;
  final String ingredientId;
  final double amount;
  final String unit; // e.g., "kg", "g", "L", "pieces"
  final DateTime addedDate;
  final DateTime? expiryDate;

  const PantryItem({
    required this.id,
    required this.userId,
    required this.ingredientId,
    required this.amount,
    required this.unit,
    required this.addedDate,
    this.expiryDate,
  });

  factory PantryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PantryItem(
      id: doc.id,
      userId: data['userId'] as String,
      ingredientId: data['ingredientId'] as String,
      amount: (data['amount'] as num).toDouble(),
      unit: data['unit'] as String,
      addedDate: (data['addedDate'] as Timestamp).toDate(),
      expiryDate: data['expiryDate'] != null
          ? (data['expiryDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'ingredientId': ingredientId,
      'amount': amount,
      'unit': unit,
      'addedDate': Timestamp.fromDate(addedDate),
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
    };
  }

  /// Check if the item is expiring soon (within 3 days)
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry >= 0 && daysUntilExpiry <= 3;
  }

  /// Check if the item is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  PantryItem copyWith({
    String? id,
    String? userId,
    String? ingredientId,
    double? amount,
    String? unit,
    DateTime? addedDate,
    DateTime? expiryDate,
  }) {
    return PantryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      ingredientId: ingredientId ?? this.ingredientId,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      addedDate: addedDate ?? this.addedDate,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    ingredientId,
    amount,
    unit,
    addedDate,
    expiryDate,
  ];
}

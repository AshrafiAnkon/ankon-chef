import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Ingredient master data (shared across all users)
class Ingredient extends Equatable {
  final String id;
  final String name;
  final String category; // e.g., "Vegetables", "Proteins", "Grains", "Spices"

  const Ingredient({
    required this.id,
    required this.name,
    required this.category,
  });

  factory Ingredient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Ingredient(
      id: doc.id,
      name: data['name'] as String,
      category: data['category'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
    };
  }

  @override
  List<Object?> get props => [id, name, category];
}

/// User's current ingredient status
class UserIngredient extends Equatable {
  final String userId;
  final String ingredientId;
  final bool isCurrent; // whether user currently has this ingredient
  final DateTime updatedAt;

  const UserIngredient({
    required this.userId,
    required this.ingredientId,
    required this.isCurrent,
    required this.updatedAt,
  });

  factory UserIngredient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserIngredient(
      userId: data['userId'] as String,
      ingredientId: data['ingredientId'] as String,
      isCurrent: data['isCurrent'] as bool,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'ingredientId': ingredientId,
      'isCurrent': isCurrent,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserIngredient copyWith({
    String? userId,
    String? ingredientId,
    bool? isCurrent,
    DateTime? updatedAt,
  }) {
    return UserIngredient(
      userId: userId ?? this.userId,
      ingredientId: ingredientId ?? this.ingredientId,
      isCurrent: isCurrent ?? this.isCurrent,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [userId, ingredientId, isCurrent, updatedAt];
}

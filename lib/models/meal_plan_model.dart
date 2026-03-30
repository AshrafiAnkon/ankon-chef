import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Meal plan model for planning meals and generating grocery lists
class MealPlan extends Equatable {
  final String id;
  final String userId;
  final DateTime planDate;
  final List<String> recipeIds; // recipes selected for this meal plan
  final DateTime createdAt;

  const MealPlan({
    required this.id,
    required this.userId,
    required this.planDate,
    required this.recipeIds,
    required this.createdAt,
  });

  factory MealPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MealPlan(
      id: doc.id,
      userId: data['userId'] as String,
      planDate: (data['planDate'] as Timestamp).toDate(),
      recipeIds: List<String>.from(data['recipeIds'] as List),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'planDate': Timestamp.fromDate(planDate),
      'recipeIds': recipeIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  MealPlan copyWith({
    String? id,
    String? userId,
    DateTime? planDate,
    List<String>? recipeIds,
    DateTime? createdAt,
  }) {
    return MealPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planDate: planDate ?? this.planDate,
      recipeIds: recipeIds ?? this.recipeIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, planDate, recipeIds, createdAt];
}

/// Grocery list item
class GroceryItem extends Equatable {
  final String ingredientId;
  final String ingredientName;
  final bool isAvailable; // whether user already has this

  const GroceryItem({
    required this.ingredientId,
    required this.ingredientName,
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [ingredientId, ingredientName, isAvailable];
}

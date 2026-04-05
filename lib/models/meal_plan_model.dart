import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Represents a single meal within a meal plan
class PlannedMeal extends Equatable {
  final String recipeId;
  final String mealPeriod; // Breakfast, Lunch, Afternoon Snacks, Dinner
  final String servingTime; // e.g. "08:30"
  final int servings;
  final String mealNotes;
  final List<String> prepReminders; // e.g. ["15 mins before"]

  const PlannedMeal({
    required this.recipeId,
    this.mealPeriod = 'Dinner',
    this.servingTime = '19:00',
    this.servings = 2,
    this.mealNotes = '',
    this.prepReminders = const [],
  });

  factory PlannedMeal.fromMap(Map<String, dynamic> data) {
    return PlannedMeal(
      recipeId: data['recipeId'] as String,
      mealPeriod: data['mealPeriod'] as String? ?? 'Dinner',
      servingTime: data['servingTime'] as String? ?? '19:00',
      servings: data['servings'] as int? ?? 2,
      mealNotes: data['mealNotes'] as String? ?? '',
      prepReminders: List<String>.from(data['prepReminders'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'mealPeriod': mealPeriod,
      'servingTime': servingTime,
      'servings': servings,
      'mealNotes': mealNotes,
      'prepReminders': prepReminders,
    };
  }

  @override
  List<Object?> get props => [
        recipeId,
        mealPeriod,
        servingTime,
        servings,
        mealNotes,
        prepReminders,
      ];
}

/// Meal plan model for planning meals and generating grocery lists
class MealPlan extends Equatable {
  final String id;
  final String userId;
  final DateTime planDate;
  final List<PlannedMeal> plannedMeals;
  final DateTime createdAt;

  const MealPlan({
    required this.id,
    required this.userId,
    required this.planDate,
    this.plannedMeals = const [],
    required this.createdAt,
  });

  /// Computed property for backward compatibility
  List<String> get recipeIds => plannedMeals.map((m) => m.recipeId).toList();

  factory MealPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Support backward compatibility where recipeIds was used
    List<PlannedMeal> meals = [];
    if (data.containsKey('plannedMeals')) {
      meals = (data['plannedMeals'] as List)
          .map((m) => PlannedMeal.fromMap(m as Map<String, dynamic>))
          .toList();
    } else if (data.containsKey('recipeIds')) {
      meals = (data['recipeIds'] as List)
          .map((id) => PlannedMeal(recipeId: id as String))
          .toList();
    }

    return MealPlan(
      id: doc.id,
      userId: data['userId'] as String,
      planDate: (data['planDate'] as Timestamp).toDate(),
      plannedMeals: meals,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'planDate': Timestamp.fromDate(planDate),
      'plannedMeals': plannedMeals.map((m) => m.toMap()).toList(),
      // Keep recipeIds for backward compatibility in the database queries if needed
      'recipeIds': plannedMeals.map((m) => m.recipeId).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  MealPlan copyWith({
    String? id,
    String? userId,
    DateTime? planDate,
    List<PlannedMeal>? plannedMeals,
    DateTime? createdAt,
  }) {
    return MealPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planDate: planDate ?? this.planDate,
      plannedMeals: plannedMeals ?? this.plannedMeals,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, planDate, plannedMeals, createdAt];
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

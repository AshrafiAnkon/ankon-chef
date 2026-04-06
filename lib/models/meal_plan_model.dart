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
      recipeId: data['recipeId']?.toString() ?? '',
      mealPeriod: data['mealPeriod']?.toString() ?? 'Dinner',
      servingTime: data['servingTime']?.toString() ?? '19:00',
      servings: data['servings'] is num ? (data['servings'] as num).toInt() : 2,
      mealNotes: data['mealNotes']?.toString() ?? '',
      prepReminders: List<String>.from((data['prepReminders'] as List?) ?? []),
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

/// Represents an override for a shopping list item
class ShoppingListOverride extends Equatable {
  final double amount;
  final String unit;

  const ShoppingListOverride({
    required this.amount,
    required this.unit,
  });

  factory ShoppingListOverride.fromMap(Map<String, dynamic> data) {
    return ShoppingListOverride(
      amount: (data['amount'] as num).toDouble(),
      unit: data['unit'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'unit': unit,
    };
  }

  @override
  List<Object?> get props => [amount, unit];
}

/// Meal plan model for planning meals and generating grocery lists
class MealPlan extends Equatable {
  final String id;
  final String userId;
  final DateTime planDate;
  final List<PlannedMeal> plannedMeals;
  final List<String> shoppingListExclusions;
  final Map<String, ShoppingListOverride> shoppingListOverrides;
  final DateTime createdAt;

  const MealPlan({
    required this.id,
    required this.userId,
    required this.planDate,
    this.plannedMeals = const [],
    this.shoppingListExclusions = const [],
    this.shoppingListOverrides = const {},
    required this.createdAt,
  });

  /// Computed property for backward compatibility
  List<String> get recipeIds => plannedMeals.map<String>((m) => m.recipeId).toList();

  factory MealPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Support backward compatibility where recipeIds was used
    List<PlannedMeal> meals = [];
    if (data['plannedMeals'] != null) {
      meals = (data['plannedMeals'] as List)
          .map((m) => PlannedMeal.fromMap(Map<String, dynamic>.from(m as Map<dynamic, dynamic>)))
          .toList();
    } else if (data['recipeIds'] != null && data['recipeIds'] is List) {
      meals = (data['recipeIds'] as List)
          .map((id) => PlannedMeal(recipeId: id?.toString() ?? ''))
          .toList();
    }

    final Map<String, ShoppingListOverride> overrides = {};
    if (data['shoppingListOverrides'] != null && data['shoppingListOverrides'] is Map) {
      final map = data['shoppingListOverrides'] as Map;
      map.forEach((key, value) {
        overrides[key.toString()] = ShoppingListOverride.fromMap(Map<String, dynamic>.from(value as Map));
      });
    }

    return MealPlan(
      id: doc.id,
      userId: data['userId']?.toString() ?? '',
      planDate: data['planDate'] is Timestamp ? (data['planDate'] as Timestamp).toDate() : DateTime.now(),
      plannedMeals: meals,
      shoppingListExclusions: List<String>.from(data['shoppingListExclusions'] ?? []),
      shoppingListOverrides: overrides,
      createdAt: data['createdAt'] is Timestamp ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'planDate': Timestamp.fromDate(planDate),
      'plannedMeals': plannedMeals.map((m) => m.toMap()).toList(),
      'shoppingListExclusions': shoppingListExclusions,
      'shoppingListOverrides': shoppingListOverrides.map((k, v) => MapEntry(k, v.toMap())),
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
    List<String>? shoppingListExclusions,
    Map<String, ShoppingListOverride>? shoppingListOverrides,
    DateTime? createdAt,
  }) {
    return MealPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planDate: planDate ?? this.planDate,
      plannedMeals: plannedMeals ?? this.plannedMeals,
      shoppingListExclusions: shoppingListExclusions ?? this.shoppingListExclusions,
      shoppingListOverrides: shoppingListOverrides ?? this.shoppingListOverrides,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, planDate, plannedMeals, shoppingListExclusions, shoppingListOverrides, createdAt];
}

/// Grocery list item
class GroceryItem extends Equatable {
  final String ingredientId;
  final String ingredientName;
  final double amount;
  final String unit;
  final bool isAvailable; // whether user already has this

  const GroceryItem({
    required this.ingredientId,
    required this.ingredientName,
    this.amount = 0,
    this.unit = '',
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [ingredientId, ingredientName, amount, unit, isAvailable];
}

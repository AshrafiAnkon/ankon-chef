import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal_plan_model.dart';
import '../models/recipe_model.dart';
import '../models/ingredient_model.dart';

/// Service for managing meal plans and grocery lists
class MealPlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all meal plans for a user
  Stream<List<MealPlan>> getMealPlans(String userId) {
    return _firestore
        .collection('mealPlans')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final plans = snapshot.docs
              .map((doc) => MealPlan.fromFirestore(doc))
              .toList();
          // Sort locally to avoid needing a composite index
          plans.sort((a, b) => a.planDate.compareTo(b.planDate));
          return plans;
        });
  }

  /// Get meal plan for a specific date
  Future<MealPlan?> getMealPlanForDate(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('mealPlans')
        .where('userId', isEqualTo: userId)
        .where(
          'planDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('planDate', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return MealPlan.fromFirestore(snapshot.docs.first);
    }
    return null;
  }

  /// Create or update meal plan
  Future<String> createOrUpdateMealPlan({
    required String userId,
    required DateTime planDate,
    required List<String> recipeIds,
    String? existingMealPlanId,
  }) async {
    if (existingMealPlanId != null) {
      // Update existing meal plan
      await _firestore.collection('mealPlans').doc(existingMealPlanId).update({
        'recipeIds': recipeIds,
      });
      return existingMealPlanId;
    } else {
      // Create new meal plan
      final docRef = _firestore.collection('mealPlans').doc();
      final mealPlan = MealPlan(
        id: docRef.id,
        userId: userId,
        planDate: planDate,
        recipeIds: recipeIds,
        createdAt: DateTime.now(),
      );

      await docRef.set(mealPlan.toFirestore());
      return docRef.id;
    }
  }

  /// Delete meal plan
  Future<void> deleteMealPlan(String mealPlanId) async {
    await _firestore.collection('mealPlans').doc(mealPlanId).delete();
  }

  /// Generate grocery list for meal plan
  Future<List<GroceryItem>> generateGroceryList({
    required List<String> recipeIds,
    required List<String> currentIngredientIds,
  }) async {
    // Get all recipes in the meal plan
    final recipeDocs = await Future.wait(
      recipeIds.map((id) => _firestore.collection('recipes').doc(id).get()),
    );

    final recipes = recipeDocs
        .where((doc) => doc.exists)
        .map((doc) => Recipe.fromFirestore(doc))
        .toList();

    // Collect all unique ingredient IDs from recipes
    final allIngredientIds = <String>{};
    for (final recipe in recipes) {
      allIngredientIds.addAll(recipe.ingredientIds);
    }

    // Get ingredient details
    final ingredientDocs = await Future.wait(
      allIngredientIds.map(
        (id) => _firestore.collection('ingredients').doc(id).get(),
      ),
    );

    final groceryItems = <GroceryItem>[];

    for (final doc in ingredientDocs) {
      if (doc.exists) {
        final ingredient = Ingredient.fromFirestore(doc);
        final isAvailable = currentIngredientIds.contains(ingredient.id);

        groceryItems.add(
          GroceryItem(
            ingredientId: ingredient.id,
            ingredientName: ingredient.name,
            isAvailable: isAvailable,
          ),
        );
      }
    }

    // Sort by availability (items to buy first)
    groceryItems.sort((a, b) {
      if (a.isAvailable == b.isAvailable) {
        return a.ingredientName.compareTo(b.ingredientName);
      }
      return a.isAvailable ? 1 : -1;
    });

    return groceryItems;
  }

  /// Get recipes for a meal plan
  Future<List<Recipe>> getRecipesForMealPlan(MealPlan mealPlan) async {
    final recipeDocs = await Future.wait(
      mealPlan.recipeIds.map(
        (id) => _firestore.collection('recipes').doc(id).get(),
      ),
    );

    return recipeDocs
        .where((doc) => doc.exists)
        .map((doc) => Recipe.fromFirestore(doc))
        .toList();
  }
}

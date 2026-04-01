import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/recipe_service.dart';
import '../models/recipe_model.dart';
import 'auth_provider.dart';
import 'ingredient_provider.dart';

part 'recipe_provider.g.dart';

/// Recipe service provider
@riverpod
RecipeService recipeService(Ref ref) {
  return RecipeService();
}

/// All recipes for current user
@riverpod
Stream<List<Recipe>> userRecipes(Ref ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }

  final service = ref.watch(recipeServiceProvider);
  return service.getRecipes(user.uid);
}

/// Search recipes by name
@riverpod
Stream<List<Recipe>> searchRecipes(Ref ref, String query) {
  final user = ref.watch(currentUserProvider);
  final service = ref.watch(recipeServiceProvider);
  if (user == null || query.isEmpty) {
    if (user == null) return Stream.value([]);
    return service.getRecipes(user.uid);
  }
  return service.searchRecipesByName(user.uid, query);
}

/// Recipes that can be made with current ingredients
@riverpod
Stream<List<Recipe>> recipesWithCurrentIngredients(Ref ref) async* {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    yield [];
    return;
  }

  final service = ref.watch(recipeServiceProvider);
  final currentIngredientsStream = ref.watch(currentIngredientIdsProvider);
  
  if (currentIngredientsStream.value == null) {
    yield [];
    return;
  }

  yield* service.getRecipesWithCurrentIngredients(user.uid, currentIngredientsStream.value!);
}

/// Recipes with 1-2 missing ingredients
@riverpod
Stream<List<Recipe>> recipesWithFewMissingIngredients(Ref ref) async* {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    yield [];
    return;
  }

  final service = ref.watch(recipeServiceProvider);
  final currentIngredientsStream = ref.watch(currentIngredientIdsProvider);
  
  if (currentIngredientsStream.value == null) {
    yield [];
    return;
  }

  yield* service.getRecipesWithFewMissingIngredients(
    user.uid,
    currentIngredientsStream.value!,
  );
}

/// Get recipe by ID
@riverpod
Future<Recipe?> recipeById(Ref ref, String recipeId) async {
  final service = ref.watch(recipeServiceProvider);
  return service.getRecipeById(recipeId);
}

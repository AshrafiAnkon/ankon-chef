import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/recipe_model.dart';
import '../models/ingredient_model.dart';
import '../models/pantry_item_model.dart';
import 'auth_provider.dart';
import 'pantry_provider.dart';
import 'ingredient_provider.dart';
import 'recipe_provider.dart';

part 'filter_recipe_provider.g.dart';

/// Filter options for recipes
class FilterOptions {
  final bool pantryIngredientsOnly;
  final bool filterByChoice;
  final List<String> selectedIngredientIds;
  final bool matchAll; // true = all, false = any

  const FilterOptions({
    this.pantryIngredientsOnly = false,
    this.filterByChoice = false,
    this.selectedIngredientIds = const [],
    this.matchAll = true,
  });

  FilterOptions copyWith({
    bool? pantryIngredientsOnly,
    bool? filterByChoice,
    List<String>? selectedIngredientIds,
    bool? matchAll,
  }) {
    return FilterOptions(
      pantryIngredientsOnly:
          pantryIngredientsOnly ?? this.pantryIngredientsOnly,
      filterByChoice: filterByChoice ?? this.filterByChoice,
      selectedIngredientIds:
          selectedIngredientIds ?? this.selectedIngredientIds,
      matchAll: matchAll ?? this.matchAll,
    );
  }
}

/// Filtered recipes based on filter options
@riverpod
Future<List<Recipe>> filteredRecipes(
  Ref ref,
  FilterOptions filterOptions,
) async {
  final user = ref.watch(currentUserProvider);

  // If no user, return empty list
  if (user == null) {
    return [];
  }

  // Get the first emission from userRecipesProvider
  final recipesAsync = ref.watch(userRecipesProvider);
  final recipes = await recipesAsync.when(
    data: (r) => Future.value(r),
    loading: () async {
      // Wait for the next value
      final stream = ref.watch(userRecipesProvider);
      return stream.when(
        data: (r) => Future.value(r),
        loading: () => Future.value(<Recipe>[]),
        error: (_, _) => Future.value(<Recipe>[]),
      );
    },
    error: (_, _) => Future.value(<Recipe>[]),
  );

  // Get pantry items
  final pantryItemsAsync = ref.watch(pantryItemsProvider);
  final pantryItems = await pantryItemsAsync.when(
    data: (p) => Future.value(p),
    loading: () async {
      final stream = ref.watch(pantryItemsProvider);
      return stream.when(
        data: (p) => Future.value(p),
        loading: () => Future.value(<PantryItem>[]),
        error: (_, _) => Future.value(<PantryItem>[]),
      );
    },
    error: (_, _) => Future.value(<PantryItem>[]),
  );

  final pantryIngredientIds = pantryItems
      .map((item) => item.ingredientId)
      .toSet();

  List<Recipe> filtered = recipes;

  // Apply filter 1: Pantry ingredients only
  if (filterOptions.pantryIngredientsOnly) {
    filtered = filtered.where((recipe) {
      return recipe.ingredientIds.every(
        (id) => pantryIngredientIds.contains(id),
      );
    }).toList();
  }

  // Apply filter 2: Filter by choice
  if (filterOptions.filterByChoice &&
      filterOptions.selectedIngredientIds.isNotEmpty) {
    filtered = filtered.where((recipe) {
      if (filterOptions.matchAll) {
        return filterOptions.selectedIngredientIds.every(
          (id) => recipe.ingredientIds.contains(id),
        );
      } else {
        return filterOptions.selectedIngredientIds.any(
          (id) => recipe.ingredientIds.contains(id),
        );
      }
    }).toList();
  }

  return filtered;
}

/// Get pantry ingredients (ingredient details from pantry items)
@riverpod
Future<List<Ingredient>> pantryIngredients(Ref ref) async {
  final pantryItemsAsync = ref.watch(pantryItemsProvider);
  final pantryItems = await pantryItemsAsync.when(
    data: (items) => Future.value(items),
    loading: () async {
      try {
        return await ref.watch(pantryItemsProvider.future);
      } catch (_) {
        return <PantryItem>[];
      }
    },
    error: (_, _) async {
      try {
        return await ref.watch(pantryItemsProvider.future);
      } catch (_) {
        return <PantryItem>[];
      }
    },
  );
  final allIngredients = await ref.watch(allIngredientsProvider.future);

  final pantryIngredientIds = pantryItems
      .map((item) => item.ingredientId)
      .toSet();

  return allIngredients
      .where((ingredient) => pantryIngredientIds.contains(ingredient.id))
      .toList();
}

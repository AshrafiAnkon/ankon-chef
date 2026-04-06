import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/recipe_model.dart';
import '../models/ingredient_model.dart';
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

  final List<String> tags;
  final bool filterByNutritionTime;
  final int? maxPrepTime;
  final int? maxCookTime;
  final int? maxCalories;
  final bool showOnlyFavorites;

  const FilterOptions({
    this.pantryIngredientsOnly = false,
    this.filterByChoice = false,
    this.selectedIngredientIds = const [],
    this.matchAll = true,
    this.tags = const [],
    this.filterByNutritionTime = false,
    this.maxPrepTime,
    this.maxCookTime,
    this.maxCalories,
    this.showOnlyFavorites = false,
  });

  FilterOptions copyWith({
    bool? pantryIngredientsOnly,
    bool? filterByChoice,
    List<String>? selectedIngredientIds,
    bool? matchAll,
    List<String>? tags,
    bool? filterByNutritionTime,
    int? maxPrepTime,
    int? maxCookTime,
    int? maxCalories,
    bool? showOnlyFavorites,
  }) {
    return FilterOptions(
      pantryIngredientsOnly:
          pantryIngredientsOnly ?? this.pantryIngredientsOnly,
      filterByChoice: filterByChoice ?? this.filterByChoice,
      selectedIngredientIds:
          selectedIngredientIds ?? this.selectedIngredientIds,
      matchAll: matchAll ?? this.matchAll,
      tags: tags ?? this.tags,
      filterByNutritionTime:
          filterByNutritionTime ?? this.filterByNutritionTime,
      maxPrepTime: maxPrepTime ?? this.maxPrepTime,
      maxCookTime: maxCookTime ?? this.maxCookTime,
      maxCalories: maxCalories ?? this.maxCalories,
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilterOptions &&
        other.pantryIngredientsOnly == pantryIngredientsOnly &&
        other.filterByChoice == filterByChoice &&
        _listEquals(other.selectedIngredientIds, selectedIngredientIds) &&
        other.matchAll == matchAll &&
        _listEquals(other.tags, tags) &&
        other.filterByNutritionTime == filterByNutritionTime &&
        other.maxPrepTime == maxPrepTime &&
        other.maxCookTime == maxCookTime &&
        other.maxCalories == maxCalories &&
        other.showOnlyFavorites == showOnlyFavorites;
  }

  @override
  int get hashCode {
    return pantryIngredientsOnly.hashCode ^
        filterByChoice.hashCode ^
        Object.hashAll(selectedIngredientIds) ^
        matchAll.hashCode ^
        Object.hashAll(tags) ^
        filterByNutritionTime.hashCode ^
        maxPrepTime.hashCode ^
        maxCookTime.hashCode ^
        maxCalories.hashCode ^
        showOnlyFavorites.hashCode;
  }

  bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Active filter options state
@riverpod
class ActiveFilterOptions extends _$ActiveFilterOptions {
  @override
  FilterOptions build() => const FilterOptions();

  void updateOptions(FilterOptions options) {
    state = options;
  }

  void clear() {
    state = const FilterOptions();
  }
}

/// Filtered recipes — watches activeFilterOptionsProvider directly so there is
/// only ever ONE provider instance. This avoids the "subscription was closed"
/// crash that occurs when a family provider is disposed mid-await while its
/// async body is still running.
@riverpod
Stream<List<Recipe>> filteredRecipes(Ref ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }

  final filterOptions = ref.watch(activeFilterOptionsProvider);

  // Watch both streams synchronously — no await, no .future
  final recipesAsync = ref.watch(userRecipesProvider);
  final pantryItemsAsync = ref.watch(pantryItemsProvider);

  // Combine: only emit when both streams have data
  final recipes = recipesAsync.value;
  final pantryItems = pantryItemsAsync.value;

  if (recipes == null || pantryItems == null) {
    // Still loading — return an empty stream that will be replaced once both
    // streams emit. Riverpod will rebuild when either stream updates.
    return Stream.value([]);
  }

  final pantryIngredientIds =
      pantryItems.map((item) => item.ingredientId).toSet();

  List<Recipe> filtered = recipes;

  // Filter 1: Pantry ingredients only
  if (filterOptions.pantryIngredientsOnly) {
    filtered = filtered.where((recipe) {
      return recipe.ingredientIds
          .every((id) => pantryIngredientIds.contains(id));
    }).toList();
  }

  // Filter 2: Filter by chosen ingredients
  if (filterOptions.filterByChoice &&
      filterOptions.selectedIngredientIds.isNotEmpty) {
    filtered = filtered.where((recipe) {
      if (filterOptions.matchAll) {
        return filterOptions.selectedIngredientIds
            .every((id) => recipe.ingredientIds.contains(id));
      } else {
        return filterOptions.selectedIngredientIds
            .any((id) => recipe.ingredientIds.contains(id));
      }
    }).toList();
  }

  // Filter 3: Tags
  if (filterOptions.tags.isNotEmpty) {
    filtered = filtered.where((recipe) {
      return filterOptions.tags.every((tag) =>
          recipe.tags.any((t) => t.toLowerCase() == tag.toLowerCase()));
    }).toList();
  }

  // Filter 4: Nutrition & Time
  if (filterOptions.filterByNutritionTime) {
    if (filterOptions.maxPrepTime != null) {
      filtered = filtered
          .where((r) => (r.prepTime ?? 0) <= filterOptions.maxPrepTime!)
          .toList();
    }
    if (filterOptions.maxCookTime != null) {
      filtered = filtered
          .where((r) => (r.cookTime ?? 0) <= filterOptions.maxCookTime!)
          .toList();
    }
    if (filterOptions.maxCalories != null) {
      filtered = filtered
          .where((r) => (r.calories ?? 0) <= filterOptions.maxCalories!)
          .toList();
    }
  }

  // Filter 5: Favorites
  if (filterOptions.showOnlyFavorites) {
    filtered = filtered.where((r) => r.isFavorite).toList();
  }

  return Stream.value(filtered);
}

/// Pantry ingredients (ingredients the user has in their pantry)
@riverpod
Future<List<Ingredient>> pantryIngredients(Ref ref) async {
  final pantryItems = await ref.watch(pantryItemsProvider.future);
  final allIngredients = await ref.watch(allIngredientsProvider.future);

  final pantryIngredientIds =
      pantryItems.map((item) => item.ingredientId).toSet();

  return allIngredients
      .where((ingredient) => pantryIngredientIds.contains(ingredient.id))
      .toList();
}

/// All ingredients used across all of the user's recipes
@riverpod
Future<List<Ingredient>> allRecipeIngredients(Ref ref) async {
  final recipesAsync = ref.watch(userRecipesProvider);
  final recipes = recipesAsync.value ?? [];

  if (recipes.isEmpty) {
    // Wait for the stream to emit
    final loaded = await ref.watch(userRecipesProvider.future);
    if (loaded.isEmpty) return [];

    final ingredientIds =
        loaded.expand((r) => r.ingredientIds).toSet();
    final allIngredients = await ref.watch(allIngredientsProvider.future);
    return allIngredients
        .where((ing) => ingredientIds.contains(ing.id))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  final ingredientIds = recipes.expand((r) => r.ingredientIds).toSet();
  final allIngredients = await ref.watch(allIngredientsProvider.future);
  return allIngredients
      .where((ing) => ingredientIds.contains(ing.id))
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));
}

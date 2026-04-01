// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Recipe service provider

@ProviderFor(recipeService)
final recipeServiceProvider = RecipeServiceProvider._();

/// Recipe service provider

final class RecipeServiceProvider
    extends $FunctionalProvider<RecipeService, RecipeService, RecipeService>
    with $Provider<RecipeService> {
  /// Recipe service provider
  RecipeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recipeServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recipeServiceHash();

  @$internal
  @override
  $ProviderElement<RecipeService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RecipeService create(Ref ref) {
    return recipeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecipeService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecipeService>(value),
    );
  }
}

String _$recipeServiceHash() => r'd0d3c637f99bea2c32b17d11e68d092043da905a';

/// All recipes for current user

@ProviderFor(userRecipes)
final userRecipesProvider = UserRecipesProvider._();

/// All recipes for current user

final class UserRecipesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Recipe>>,
          List<Recipe>,
          Stream<List<Recipe>>
        >
    with $FutureModifier<List<Recipe>>, $StreamProvider<List<Recipe>> {
  /// All recipes for current user
  UserRecipesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userRecipesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userRecipesHash();

  @$internal
  @override
  $StreamProviderElement<List<Recipe>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Recipe>> create(Ref ref) {
    return userRecipes(ref);
  }
}

String _$userRecipesHash() => r'c4536ca397d82f870117f7b3cca4e377a9ac6fd4';

/// Search recipes by name

@ProviderFor(searchRecipes)
final searchRecipesProvider = SearchRecipesFamily._();

/// Search recipes by name

final class SearchRecipesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Recipe>>,
          List<Recipe>,
          Stream<List<Recipe>>
        >
    with $FutureModifier<List<Recipe>>, $StreamProvider<List<Recipe>> {
  /// Search recipes by name
  SearchRecipesProvider._({
    required SearchRecipesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchRecipesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchRecipesHash();

  @override
  String toString() {
    return r'searchRecipesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Recipe>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Recipe>> create(Ref ref) {
    final argument = this.argument as String;
    return searchRecipes(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchRecipesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchRecipesHash() => r'72e87b6b5fff8a610dad5a28efdd2b98d792553f';

/// Search recipes by name

final class SearchRecipesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Recipe>>, String> {
  SearchRecipesFamily._()
    : super(
        retry: null,
        name: r'searchRecipesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Search recipes by name

  SearchRecipesProvider call(String query) =>
      SearchRecipesProvider._(argument: query, from: this);

  @override
  String toString() => r'searchRecipesProvider';
}

/// Recipes that can be made with current ingredients

@ProviderFor(recipesWithCurrentIngredients)
final recipesWithCurrentIngredientsProvider =
    RecipesWithCurrentIngredientsProvider._();

/// Recipes that can be made with current ingredients

final class RecipesWithCurrentIngredientsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Recipe>>,
          List<Recipe>,
          Stream<List<Recipe>>
        >
    with $FutureModifier<List<Recipe>>, $StreamProvider<List<Recipe>> {
  /// Recipes that can be made with current ingredients
  RecipesWithCurrentIngredientsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recipesWithCurrentIngredientsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recipesWithCurrentIngredientsHash();

  @$internal
  @override
  $StreamProviderElement<List<Recipe>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Recipe>> create(Ref ref) {
    return recipesWithCurrentIngredients(ref);
  }
}

String _$recipesWithCurrentIngredientsHash() =>
    r'8a365a7c50b4830b93c3bdc5b4f99ecbf4ab5ab9';

/// Recipes with 1-2 missing ingredients

@ProviderFor(recipesWithFewMissingIngredients)
final recipesWithFewMissingIngredientsProvider =
    RecipesWithFewMissingIngredientsProvider._();

/// Recipes with 1-2 missing ingredients

final class RecipesWithFewMissingIngredientsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Recipe>>,
          List<Recipe>,
          Stream<List<Recipe>>
        >
    with $FutureModifier<List<Recipe>>, $StreamProvider<List<Recipe>> {
  /// Recipes with 1-2 missing ingredients
  RecipesWithFewMissingIngredientsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recipesWithFewMissingIngredientsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recipesWithFewMissingIngredientsHash();

  @$internal
  @override
  $StreamProviderElement<List<Recipe>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Recipe>> create(Ref ref) {
    return recipesWithFewMissingIngredients(ref);
  }
}

String _$recipesWithFewMissingIngredientsHash() =>
    r'bfd15f95b758e8bd50c5ccb30989199e1fb34621';

/// Get recipe by ID

@ProviderFor(recipeById)
final recipeByIdProvider = RecipeByIdFamily._();

/// Get recipe by ID

final class RecipeByIdProvider
    extends $FunctionalProvider<AsyncValue<Recipe?>, Recipe?, FutureOr<Recipe?>>
    with $FutureModifier<Recipe?>, $FutureProvider<Recipe?> {
  /// Get recipe by ID
  RecipeByIdProvider._({
    required RecipeByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'recipeByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recipeByIdHash();

  @override
  String toString() {
    return r'recipeByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Recipe?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Recipe?> create(Ref ref) {
    final argument = this.argument as String;
    return recipeById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecipeByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recipeByIdHash() => r'22b3070c98dc9decdd8a6c75a7db454cb8cd7057';

/// Get recipe by ID

final class RecipeByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Recipe?>, String> {
  RecipeByIdFamily._()
    : super(
        retry: null,
        name: r'recipeByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Get recipe by ID

  RecipeByIdProvider call(String recipeId) =>
      RecipeByIdProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'recipeByIdProvider';
}

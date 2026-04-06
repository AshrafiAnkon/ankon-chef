// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_recipe_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Active filter options state

@ProviderFor(ActiveFilterOptions)
final activeFilterOptionsProvider = ActiveFilterOptionsProvider._();

/// Active filter options state
final class ActiveFilterOptionsProvider
    extends $NotifierProvider<ActiveFilterOptions, FilterOptions> {
  /// Active filter options state
  ActiveFilterOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeFilterOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeFilterOptionsHash();

  @$internal
  @override
  ActiveFilterOptions create() => ActiveFilterOptions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FilterOptions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FilterOptions>(value),
    );
  }
}

String _$activeFilterOptionsHash() =>
    r'549e21c991e76ab2fc452488a4f2a48f532308d3';

/// Active filter options state

abstract class _$ActiveFilterOptions extends $Notifier<FilterOptions> {
  FilterOptions build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FilterOptions, FilterOptions>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FilterOptions, FilterOptions>,
              FilterOptions,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Filtered recipes — watches activeFilterOptionsProvider directly so there is
/// only ever ONE provider instance. This avoids the "subscription was closed"
/// crash that occurs when a family provider is disposed mid-await while its
/// async body is still running.

@ProviderFor(filteredRecipes)
final filteredRecipesProvider = FilteredRecipesProvider._();

/// Filtered recipes — watches activeFilterOptionsProvider directly so there is
/// only ever ONE provider instance. This avoids the "subscription was closed"
/// crash that occurs when a family provider is disposed mid-await while its
/// async body is still running.

final class FilteredRecipesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Recipe>>,
          List<Recipe>,
          Stream<List<Recipe>>
        >
    with $FutureModifier<List<Recipe>>, $StreamProvider<List<Recipe>> {
  /// Filtered recipes — watches activeFilterOptionsProvider directly so there is
  /// only ever ONE provider instance. This avoids the "subscription was closed"
  /// crash that occurs when a family provider is disposed mid-await while its
  /// async body is still running.
  FilteredRecipesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredRecipesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredRecipesHash();

  @$internal
  @override
  $StreamProviderElement<List<Recipe>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Recipe>> create(Ref ref) {
    return filteredRecipes(ref);
  }
}

String _$filteredRecipesHash() => r'9134de16628423fdf31af839d4df05fb54ef871f';

/// Pantry ingredients (ingredients the user has in their pantry)

@ProviderFor(pantryIngredients)
final pantryIngredientsProvider = PantryIngredientsProvider._();

/// Pantry ingredients (ingredients the user has in their pantry)

final class PantryIngredientsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Ingredient>>,
          List<Ingredient>,
          FutureOr<List<Ingredient>>
        >
    with $FutureModifier<List<Ingredient>>, $FutureProvider<List<Ingredient>> {
  /// Pantry ingredients (ingredients the user has in their pantry)
  PantryIngredientsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pantryIngredientsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pantryIngredientsHash();

  @$internal
  @override
  $FutureProviderElement<List<Ingredient>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Ingredient>> create(Ref ref) {
    return pantryIngredients(ref);
  }
}

String _$pantryIngredientsHash() => r'dbd303895401255c46140370807d460a16253951';

/// All ingredients used across all of the user's recipes

@ProviderFor(allRecipeIngredients)
final allRecipeIngredientsProvider = AllRecipeIngredientsProvider._();

/// All ingredients used across all of the user's recipes

final class AllRecipeIngredientsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Ingredient>>,
          List<Ingredient>,
          FutureOr<List<Ingredient>>
        >
    with $FutureModifier<List<Ingredient>>, $FutureProvider<List<Ingredient>> {
  /// All ingredients used across all of the user's recipes
  AllRecipeIngredientsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allRecipeIngredientsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allRecipeIngredientsHash();

  @$internal
  @override
  $FutureProviderElement<List<Ingredient>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Ingredient>> create(Ref ref) {
    return allRecipeIngredients(ref);
  }
}

String _$allRecipeIngredientsHash() =>
    r'f08432e46e141560124b7478f713a7e7d7e0b3d9';

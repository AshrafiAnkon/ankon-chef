// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_recipe_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Filtered recipes based on filter options

@ProviderFor(filteredRecipes)
final filteredRecipesProvider = FilteredRecipesFamily._();

/// Filtered recipes based on filter options

final class FilteredRecipesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Recipe>>,
          List<Recipe>,
          FutureOr<List<Recipe>>
        >
    with $FutureModifier<List<Recipe>>, $FutureProvider<List<Recipe>> {
  /// Filtered recipes based on filter options
  FilteredRecipesProvider._({
    required FilteredRecipesFamily super.from,
    required FilterOptions super.argument,
  }) : super(
         retry: null,
         name: r'filteredRecipesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredRecipesHash();

  @override
  String toString() {
    return r'filteredRecipesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Recipe>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Recipe>> create(Ref ref) {
    final argument = this.argument as FilterOptions;
    return filteredRecipes(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredRecipesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredRecipesHash() => r'9a707af73506a37b903d748a020f06605bab234e';

/// Filtered recipes based on filter options

final class FilteredRecipesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Recipe>>, FilterOptions> {
  FilteredRecipesFamily._()
    : super(
        retry: null,
        name: r'filteredRecipesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Filtered recipes based on filter options

  FilteredRecipesProvider call(FilterOptions filterOptions) =>
      FilteredRecipesProvider._(argument: filterOptions, from: this);

  @override
  String toString() => r'filteredRecipesProvider';
}

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

/// Get pantry ingredients (ingredient details from pantry items)

@ProviderFor(pantryIngredients)
final pantryIngredientsProvider = PantryIngredientsProvider._();

/// Get pantry ingredients (ingredient details from pantry items)

final class PantryIngredientsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Ingredient>>,
          List<Ingredient>,
          FutureOr<List<Ingredient>>
        >
    with $FutureModifier<List<Ingredient>>, $FutureProvider<List<Ingredient>> {
  /// Get pantry ingredients (ingredient details from pantry items)
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

String _$pantryIngredientsHash() => r'e287d32202e9faf0ee406f828aeb1e8a8b3f65d0';

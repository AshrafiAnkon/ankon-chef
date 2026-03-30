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

String _$filteredRecipesHash() => r'a967f295572b2a3ea7c233c6741146027481bfaa';

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

String _$pantryIngredientsHash() => r'4768d5d842919ae7f9784a808962ad6daafc32dc';

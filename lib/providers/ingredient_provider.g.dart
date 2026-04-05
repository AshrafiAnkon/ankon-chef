// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Ingredient service provider

@ProviderFor(ingredientService)
final ingredientServiceProvider = IngredientServiceProvider._();

/// Ingredient service provider

final class IngredientServiceProvider
    extends
        $FunctionalProvider<
          IngredientService,
          IngredientService,
          IngredientService
        >
    with $Provider<IngredientService> {
  /// Ingredient service provider
  IngredientServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ingredientServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ingredientServiceHash();

  @$internal
  @override
  $ProviderElement<IngredientService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IngredientService create(Ref ref) {
    return ingredientService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IngredientService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IngredientService>(value),
    );
  }
}

String _$ingredientServiceHash() => r'639a7c151ea1b677a21d7c47b38efec397127d61';

/// All ingredients provider

@ProviderFor(allIngredients)
final allIngredientsProvider = AllIngredientsProvider._();

/// All ingredients provider

final class AllIngredientsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Ingredient>>,
          List<Ingredient>,
          Stream<List<Ingredient>>
        >
    with $FutureModifier<List<Ingredient>>, $StreamProvider<List<Ingredient>> {
  /// All ingredients provider
  AllIngredientsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allIngredientsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allIngredientsHash();

  @$internal
  @override
  $StreamProviderElement<List<Ingredient>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Ingredient>> create(Ref ref) {
    return allIngredients(ref);
  }
}

String _$allIngredientsHash() => r'8d59c742849b836e1f8570043a755bbbca729948';

/// Ingredients by category provider

@ProviderFor(ingredientsByCategory)
final ingredientsByCategoryProvider = IngredientsByCategoryFamily._();

/// Ingredients by category provider

final class IngredientsByCategoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Ingredient>>,
          List<Ingredient>,
          Stream<List<Ingredient>>
        >
    with $FutureModifier<List<Ingredient>>, $StreamProvider<List<Ingredient>> {
  /// Ingredients by category provider
  IngredientsByCategoryProvider._({
    required IngredientsByCategoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ingredientsByCategoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ingredientsByCategoryHash();

  @override
  String toString() {
    return r'ingredientsByCategoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Ingredient>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Ingredient>> create(Ref ref) {
    final argument = this.argument as String;
    return ingredientsByCategory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IngredientsByCategoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ingredientsByCategoryHash() =>
    r'5b552870ba4851e380dec8778ad5cb6d5fb915cb';

/// Ingredients by category provider

final class IngredientsByCategoryFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Ingredient>>, String> {
  IngredientsByCategoryFamily._()
    : super(
        retry: null,
        name: r'ingredientsByCategoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Ingredients by category provider

  IngredientsByCategoryProvider call(String category) =>
      IngredientsByCategoryProvider._(argument: category, from: this);

  @override
  String toString() => r'ingredientsByCategoryProvider';
}

/// Current user ingredients provider

@ProviderFor(currentUserIngredients)
final currentUserIngredientsProvider = CurrentUserIngredientsProvider._();

/// Current user ingredients provider

final class CurrentUserIngredientsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserIngredient>>,
          List<UserIngredient>,
          Stream<List<UserIngredient>>
        >
    with
        $FutureModifier<List<UserIngredient>>,
        $StreamProvider<List<UserIngredient>> {
  /// Current user ingredients provider
  CurrentUserIngredientsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserIngredientsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserIngredientsHash();

  @$internal
  @override
  $StreamProviderElement<List<UserIngredient>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<UserIngredient>> create(Ref ref) {
    return currentUserIngredients(ref);
  }
}

String _$currentUserIngredientsHash() =>
    r'f7a0716f1195aa9a027d6244787ce85d2db456d4';

/// Current ingredient IDs provider (for filtering)

@ProviderFor(currentIngredientIds)
final currentIngredientIdsProvider = CurrentIngredientIdsProvider._();

/// Current ingredient IDs provider (for filtering)

final class CurrentIngredientIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  /// Current ingredient IDs provider (for filtering)
  CurrentIngredientIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentIngredientIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentIngredientIdsHash();

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    return currentIngredientIds(ref);
  }
}

String _$currentIngredientIdsHash() =>
    r'56d94c28c5206bdd9fd15cf1c21204185a562b74';

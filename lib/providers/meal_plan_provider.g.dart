// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Meal plan service provider

@ProviderFor(mealPlanService)
final mealPlanServiceProvider = MealPlanServiceProvider._();

/// Meal plan service provider

final class MealPlanServiceProvider
    extends
        $FunctionalProvider<MealPlanService, MealPlanService, MealPlanService>
    with $Provider<MealPlanService> {
  /// Meal plan service provider
  MealPlanServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mealPlanServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mealPlanServiceHash();

  @$internal
  @override
  $ProviderElement<MealPlanService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MealPlanService create(Ref ref) {
    return mealPlanService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MealPlanService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MealPlanService>(value),
    );
  }
}

String _$mealPlanServiceHash() => r'a371d8b4773288caf595823af6e02bd17699bf03';

/// All meal plans for current user

@ProviderFor(mealPlans)
final mealPlansProvider = MealPlansProvider._();

/// All meal plans for current user

final class MealPlansProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MealPlan>>,
          List<MealPlan>,
          Stream<List<MealPlan>>
        >
    with $FutureModifier<List<MealPlan>>, $StreamProvider<List<MealPlan>> {
  /// All meal plans for current user
  MealPlansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mealPlansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mealPlansHash();

  @$internal
  @override
  $StreamProviderElement<List<MealPlan>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MealPlan>> create(Ref ref) {
    return mealPlans(ref);
  }
}

String _$mealPlansHash() => r'e0e6e19c58bf23941b34ecc8936dc6ec9ad491f3';

/// Meal plan for a specific date

@ProviderFor(mealPlanForDate)
final mealPlanForDateProvider = MealPlanForDateFamily._();

/// Meal plan for a specific date

final class MealPlanForDateProvider
    extends
        $FunctionalProvider<
          AsyncValue<MealPlan?>,
          MealPlan?,
          FutureOr<MealPlan?>
        >
    with $FutureModifier<MealPlan?>, $FutureProvider<MealPlan?> {
  /// Meal plan for a specific date
  MealPlanForDateProvider._({
    required MealPlanForDateFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'mealPlanForDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mealPlanForDateHash();

  @override
  String toString() {
    return r'mealPlanForDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MealPlan?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<MealPlan?> create(Ref ref) {
    final argument = this.argument as DateTime;
    return mealPlanForDate(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MealPlanForDateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mealPlanForDateHash() => r'1d776ecf60e48978a36b26d6d237bf29c6fc72c2';

/// Meal plan for a specific date

final class MealPlanForDateFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MealPlan?>, DateTime> {
  MealPlanForDateFamily._()
    : super(
        retry: null,
        name: r'mealPlanForDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Meal plan for a specific date

  MealPlanForDateProvider call(DateTime date) =>
      MealPlanForDateProvider._(argument: date, from: this);

  @override
  String toString() => r'mealPlanForDateProvider';
}

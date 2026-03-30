// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pantry_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Pantry service provider

@ProviderFor(pantryService)
final pantryServiceProvider = PantryServiceProvider._();

/// Pantry service provider

final class PantryServiceProvider
    extends $FunctionalProvider<PantryService, PantryService, PantryService>
    with $Provider<PantryService> {
  /// Pantry service provider
  PantryServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pantryServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pantryServiceHash();

  @$internal
  @override
  $ProviderElement<PantryService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PantryService create(Ref ref) {
    return pantryService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PantryService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PantryService>(value),
    );
  }
}

String _$pantryServiceHash() => r'60f1d8217ffa86e590ca10a5e8a3319acaa9421e';

/// All pantry items for current user

@ProviderFor(pantryItems)
final pantryItemsProvider = PantryItemsProvider._();

/// All pantry items for current user

final class PantryItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PantryItem>>,
          List<PantryItem>,
          Stream<List<PantryItem>>
        >
    with $FutureModifier<List<PantryItem>>, $StreamProvider<List<PantryItem>> {
  /// All pantry items for current user
  PantryItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pantryItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pantryItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<PantryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PantryItem>> create(Ref ref) {
    return pantryItems(ref);
  }
}

String _$pantryItemsHash() => r'ddca5bb6424d9144dc1d11af3b20c2a0c6665406';

/// Expiring pantry items

@ProviderFor(expiringItems)
final expiringItemsProvider = ExpiringItemsProvider._();

/// Expiring pantry items

final class ExpiringItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PantryItem>>,
          List<PantryItem>,
          Stream<List<PantryItem>>
        >
    with $FutureModifier<List<PantryItem>>, $StreamProvider<List<PantryItem>> {
  /// Expiring pantry items
  ExpiringItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expiringItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expiringItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<PantryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PantryItem>> create(Ref ref) {
    return expiringItems(ref);
  }
}

String _$expiringItemsHash() => r'e3d865483c42b889770ae68bdbf6f1db94e6d1ef';

/// Expired pantry items

@ProviderFor(expiredItems)
final expiredItemsProvider = ExpiredItemsProvider._();

/// Expired pantry items

final class ExpiredItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PantryItem>>,
          List<PantryItem>,
          Stream<List<PantryItem>>
        >
    with $FutureModifier<List<PantryItem>>, $StreamProvider<List<PantryItem>> {
  /// Expired pantry items
  ExpiredItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expiredItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expiredItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<PantryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PantryItem>> create(Ref ref) {
    return expiredItems(ref);
  }
}

String _$expiredItemsHash() => r'68a780abe5ad41f2357f911468d8e3099ef6430d';

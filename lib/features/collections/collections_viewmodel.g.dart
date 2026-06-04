// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collections_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(collectionsRepository)
final collectionsRepositoryProvider = CollectionsRepositoryProvider._();

final class CollectionsRepositoryProvider
    extends
        $FunctionalProvider<
          CollectionsRepository,
          CollectionsRepository,
          CollectionsRepository
        >
    with $Provider<CollectionsRepository> {
  CollectionsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionsRepositoryHash();

  @$internal
  @override
  $ProviderElement<CollectionsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CollectionsRepository create(Ref ref) {
    return collectionsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CollectionsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CollectionsRepository>(value),
    );
  }
}

String _$collectionsRepositoryHash() =>
    r'5a6853a3237d753480f346471e49cab757087371';

@ProviderFor(collectionsViewModel)
final collectionsViewModelProvider = CollectionsViewModelProvider._();

final class CollectionsViewModelProvider
    extends
        $FunctionalProvider<
          CollectionsState,
          CollectionsState,
          CollectionsState
        >
    with $Provider<CollectionsState> {
  CollectionsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionsViewModelHash();

  @$internal
  @override
  $ProviderElement<CollectionsState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CollectionsState create(Ref ref) {
    return collectionsViewModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CollectionsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CollectionsState>(value),
    );
  }
}

String _$collectionsViewModelHash() =>
    r'6d4398a00002f3f1bd58a96ce3b3f2d897c8c934';

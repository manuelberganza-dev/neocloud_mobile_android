// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dte_query_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dteQueryRepository)
final dteQueryRepositoryProvider = DteQueryRepositoryProvider._();

final class DteQueryRepositoryProvider
    extends
        $FunctionalProvider<
          DteQueryRepository,
          DteQueryRepository,
          DteQueryRepository
        >
    with $Provider<DteQueryRepository> {
  DteQueryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dteQueryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dteQueryRepositoryHash();

  @$internal
  @override
  $ProviderElement<DteQueryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DteQueryRepository create(Ref ref) {
    return dteQueryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DteQueryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DteQueryRepository>(value),
    );
  }
}

String _$dteQueryRepositoryHash() =>
    r'1ebe8c9138f7d701b98a752c0bb6c4812760a493';

@ProviderFor(dteQueryViewModel)
final dteQueryViewModelProvider = DteQueryViewModelProvider._();

final class DteQueryViewModelProvider
    extends $FunctionalProvider<DteQueryState, DteQueryState, DteQueryState>
    with $Provider<DteQueryState> {
  DteQueryViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dteQueryViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dteQueryViewModelHash();

  @$internal
  @override
  $ProviderElement<DteQueryState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DteQueryState create(Ref ref) {
    return dteQueryViewModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DteQueryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DteQueryState>(value),
    );
  }
}

String _$dteQueryViewModelHash() => r'51c826f3732f13ca69ed0bf662ede62ff8ffb7da';

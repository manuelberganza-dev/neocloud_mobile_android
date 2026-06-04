// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'neoscan_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(neoScanRepository)
final neoScanRepositoryProvider = NeoScanRepositoryProvider._();

final class NeoScanRepositoryProvider
    extends
        $FunctionalProvider<
          NeoScanRepository,
          NeoScanRepository,
          NeoScanRepository
        >
    with $Provider<NeoScanRepository> {
  NeoScanRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'neoScanRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$neoScanRepositoryHash();

  @$internal
  @override
  $ProviderElement<NeoScanRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NeoScanRepository create(Ref ref) {
    return neoScanRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NeoScanRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NeoScanRepository>(value),
    );
  }
}

String _$neoScanRepositoryHash() => r'2cf06b258133c74e645048e8763b7860fc8db8f5';

@ProviderFor(neoScanViewModel)
final neoScanViewModelProvider = NeoScanViewModelProvider._();

final class NeoScanViewModelProvider
    extends $FunctionalProvider<NeoScanState, NeoScanState, NeoScanState>
    with $Provider<NeoScanState> {
  NeoScanViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'neoScanViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$neoScanViewModelHash();

  @$internal
  @override
  $ProviderElement<NeoScanState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NeoScanState create(Ref ref) {
    return neoScanViewModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NeoScanState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NeoScanState>(value),
    );
  }
}

String _$neoScanViewModelHash() => r'ff2eac5bd705ce57660843cd9a5fed122771a8e5';

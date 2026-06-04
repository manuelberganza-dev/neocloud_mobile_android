// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(invoiceRepository)
final invoiceRepositoryProvider = InvoiceRepositoryProvider._();

final class InvoiceRepositoryProvider
    extends
        $FunctionalProvider<
          InvoiceRepository,
          InvoiceRepository,
          InvoiceRepository
        >
    with $Provider<InvoiceRepository> {
  InvoiceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'invoiceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$invoiceRepositoryHash();

  @$internal
  @override
  $ProviderElement<InvoiceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InvoiceRepository create(Ref ref) {
    return invoiceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InvoiceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InvoiceRepository>(value),
    );
  }
}

String _$invoiceRepositoryHash() => r'e55bea0a52e93ce147ddd770523dc326edf8e3a0';

@ProviderFor(invoiceViewModel)
final invoiceViewModelProvider = InvoiceViewModelProvider._();

final class InvoiceViewModelProvider
    extends $FunctionalProvider<InvoiceState, InvoiceState, InvoiceState>
    with $Provider<InvoiceState> {
  InvoiceViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'invoiceViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$invoiceViewModelHash();

  @$internal
  @override
  $ProviderElement<InvoiceState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  InvoiceState create(Ref ref) {
    return invoiceViewModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InvoiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InvoiceState>(value),
    );
  }
}

String _$invoiceViewModelHash() => r'766072448b7c327fb2342a8c047b1fad53e7103b';

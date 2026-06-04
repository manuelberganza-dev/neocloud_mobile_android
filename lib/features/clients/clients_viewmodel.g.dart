// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clients_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(clientsRepository)
final clientsRepositoryProvider = ClientsRepositoryProvider._();

final class ClientsRepositoryProvider
    extends
        $FunctionalProvider<
          ClientsRepository,
          ClientsRepository,
          ClientsRepository
        >
    with $Provider<ClientsRepository> {
  ClientsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ClientsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClientsRepository create(Ref ref) {
    return clientsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClientsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClientsRepository>(value),
    );
  }
}

String _$clientsRepositoryHash() => r'd9db16a18db2da4b87f338940a193ecd64191b20';

@ProviderFor(clientsViewModel)
final clientsViewModelProvider = ClientsViewModelProvider._();

final class ClientsViewModelProvider
    extends
        $FunctionalProvider<
          ClientDetailState,
          ClientDetailState,
          ClientDetailState
        >
    with $Provider<ClientDetailState> {
  ClientsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientsViewModelHash();

  @$internal
  @override
  $ProviderElement<ClientDetailState> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClientDetailState create(Ref ref) {
    return clientsViewModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClientDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClientDetailState>(value),
    );
  }
}

String _$clientsViewModelHash() => r'389bee674ab773f454fa8f699fb6f85f67d7b6a7';

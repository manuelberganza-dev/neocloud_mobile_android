// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuthViewModel)
final authViewModelProvider = AuthViewModelProvider._();

final class AuthViewModelProvider
    extends $AsyncNotifierProvider<AuthViewModel, AuthState> {
  AuthViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authViewModelHash();

  @$internal
  @override
  AuthViewModel create() => AuthViewModel();
}

String _$authViewModelHash() => r'400e01a715eb23fda0557b050c447a38c092cfbc';

abstract class _$AuthViewModel extends $AsyncNotifier<AuthState> {
  FutureOr<AuthState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthState>, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthState>, AuthState>,
              AsyncValue<AuthState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(healthCheck)
final healthCheckProvider = HealthCheckProvider._();

final class HealthCheckProvider
    extends
        $FunctionalProvider<
          AsyncValue<HealthStatus>,
          HealthStatus,
          FutureOr<HealthStatus>
        >
    with $FutureModifier<HealthStatus>, $FutureProvider<HealthStatus> {
  HealthCheckProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthCheckProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthCheckHash();

  @$internal
  @override
  $FutureProviderElement<HealthStatus> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HealthStatus> create(Ref ref) {
    return healthCheck(ref);
  }
}

String _$healthCheckHash() => r'e6a9e041107dd2e7b6285cb56452876fee1b8c7b';

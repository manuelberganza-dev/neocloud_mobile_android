import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/api_exception.dart';
import 'auth_repository.dart';
import 'models/auth_models.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  Future<AuthState> build() async {
    final session = await ref.watch(authRepositoryProvider).restoreSession();
    return session == null
        ? const AuthState.unauthenticated()
        : AuthState(isCheckingSession: false, session: session);
  }

  Future<void> login({
    required String usernameOrEmail,
    required String password,
    String? mfaCode,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(
            usernameOrEmail: usernameOrEmail,
            password: password,
            mfaCode: mfaCode,
          );
      return AuthState(isCheckingSession: false, session: session);
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(AuthState.unauthenticated());
  }

  bool hasPermission(String permission) {
    if (!state.hasValue) {
      return false;
    }

    return state.requireValue.hasPermission(permission);
  }

  String friendlyError(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'No se pudo completar la operacion. Revisa la conexion e intenta de nuevo.';
  }
}

@riverpod
Future<HealthStatus> healthCheck(Ref ref) {
  return ref.watch(authRepositoryProvider).healthCheck();
}

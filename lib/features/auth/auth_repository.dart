import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/security/token_storage.dart';
import 'models/auth_models.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  const AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage;

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<HealthStatus> healthCheck() {
    return _apiClient.getData<HealthStatus>(
      ApiEndpoints.health,
      fromJson: HealthStatus.fromJson,
    );
  }

  Future<AuthSession?> restoreSession() async {
    final tokens = await _tokenStorage.read();
    if (tokens == null) {
      return null;
    }

    try {
      final user = await me();
      if (user.isSuperAdmin || user.empresaId == null) {
        await _tokenStorage.clear();
        return null;
      }

      return AuthSession(
        user: user,
        accessTokenExpiresAt: tokens.accessTokenExpiresAt,
        refreshTokenExpiresAt: tokens.refreshTokenExpiresAt,
      );
    } catch (_) {
      await _tokenStorage.clear();
      return null;
    }
  }

  Future<AuthSession> login({
    required String usernameOrEmail,
    required String password,
    String? mfaCode,
  }) async {
    final response = await _apiClient.postData<LoginResponse>(
      ApiEndpoints.authLogin,
      data: {
        'usernameOrEmail': usernameOrEmail,
        'password': password,
        'mfaCode': mfaCode?.trim().isEmpty == true ? null : mfaCode,
      },
      fromJson: LoginResponse.fromJson,
    );

    if (response.user.isSuperAdmin || response.user.empresaId == null) {
      throw const ApiException(
        message:
            'Esta cuenta es administrativa. Usa el panel web para tareas SuperAdmin.',
        statusCode: 403,
        errors: ['MOBILE_SUPERADMIN_NOT_SUPPORTED'],
      );
    }

    await _tokenStorage.save(
      StoredTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        accessTokenExpiresAt: response.accessTokenExpiresAt,
        refreshTokenExpiresAt: response.refreshTokenExpiresAt,
      ),
    );

    return AuthSession(
      user: response.user,
      accessTokenExpiresAt: response.accessTokenExpiresAt,
      refreshTokenExpiresAt: response.refreshTokenExpiresAt,
    );
  }

  Future<AuthUser> me() {
    return _apiClient.getData<AuthUser>(
      ApiEndpoints.authMe,
      fromJson: AuthUser.fromJson,
    );
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _apiClient.postVoid(
          ApiEndpoints.authLogout,
          data: {'refreshToken': refreshToken},
        );
      }
    } finally {
      await _tokenStorage.clear();
    }
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
}

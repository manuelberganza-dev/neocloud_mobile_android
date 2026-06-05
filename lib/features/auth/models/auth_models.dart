class AuthUser {
  const AuthUser({
    required this.id,
    required this.username,
    required this.tipoUsuarioCodigo,
    required this.roles,
    required this.permisos,
    this.empresaId,
    this.email,
    this.nombreCompleto,
  });

  final int id;
  final int? empresaId;
  final String username;
  final String? email;
  final String? nombreCompleto;
  final String tipoUsuarioCodigo;
  final List<String> roles;
  final List<String> permisos;

  bool get isSuperAdmin => tipoUsuarioCodigo.toUpperCase() == 'SUPERADMIN';

  bool hasPermission(String permission) {
    return permisos.contains(permission);
  }

  factory AuthUser.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;

    return AuthUser(
      id: (map['id'] as num?)?.toInt() ?? 0,
      empresaId: (map['empresaId'] as num?)?.toInt(),
      username: map['username']?.toString() ?? '',
      email: map['email'] as String?,
      nombreCompleto: map['nombreCompleto'] as String?,
      tipoUsuarioCodigo: map['tipoUsuarioCodigo']?.toString() ?? '',
      roles: (map['roles'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      permisos: (map['permisos'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}

class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.mfaEnrollmentRequired,
    this.accessTokenExpiresAt,
    this.refreshTokenExpiresAt,
  });

  final String accessToken;
  final DateTime? accessTokenExpiresAt;
  final String refreshToken;
  final DateTime? refreshTokenExpiresAt;
  final AuthUser user;
  final bool mfaEnrollmentRequired;

  factory LoginResponse.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;

    return LoginResponse(
      accessToken: map['accessToken'] as String,
      accessTokenExpiresAt: DateTime.tryParse(
        map['accessTokenExpiresAt']?.toString() ?? '',
      ),
      refreshToken: map['refreshToken'] as String,
      refreshTokenExpiresAt: DateTime.tryParse(
        map['refreshTokenExpiresAt']?.toString() ?? '',
      ),
      user: AuthUser.fromJson(map['user']),
      mfaEnrollmentRequired: map['mfaEnrollmentRequired'] == true,
    );
  }
}

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
  });

  final AuthUser user;
  final DateTime? accessTokenExpiresAt;
  final DateTime? refreshTokenExpiresAt;

  bool hasPermission(String permission) => user.hasPermission(permission);
}

class AuthState {
  const AuthState({required this.isCheckingSession, this.session});

  const AuthState.unauthenticated() : isCheckingSession = false, session = null;

  const AuthState.checking() : isCheckingSession = true, session = null;

  final bool isCheckingSession;
  final AuthSession? session;

  bool get isAuthenticated => session != null;

  AuthUser? get user => session?.user;

  bool hasPermission(String permission) {
    return session?.hasPermission(permission) ?? false;
  }
}

class HealthStatus {
  const HealthStatus({required this.status, required this.service});

  final String status;
  final String service;

  bool get isOk => status.toLowerCase() == 'ok';

  factory HealthStatus.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;

    return HealthStatus(
      status: map['status']?.toString() ?? 'unknown',
      service: map['service']?.toString() ?? 'NeoSTP.Api',
    );
  }
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.username,
    required this.tipoUsuarioCodigo,
    required this.roles,
    required this.permisos,
    this.empresaId,
    this.empresaNombre,
    this.empresaNombreComercial,
    this.email,
    this.nombreCompleto,
  });

  final int id;
  final int? empresaId;
  final String? empresaNombre;
  final String? empresaNombreComercial;
  final String username;
  final String? email;
  final String? nombreCompleto;
  final String tipoUsuarioCodigo;
  final List<String> roles;
  final List<String> permisos;

  bool get isSuperAdmin => tipoUsuarioCodigo.toUpperCase() == 'SUPERADMIN';

  String get displayName {
    return _cleanText(nombreCompleto) ?? _cleanText(username) ?? 'Usuario';
  }

  String get companyName {
    return _cleanText(empresaNombreComercial) ??
        _cleanText(empresaNombre) ??
        (empresaId == null ? 'Empresa' : 'Empresa #$empresaId');
  }

  String get roleLabel {
    if (roles.isNotEmpty) {
      return roles.join(', ');
    }

    return _cleanText(tipoUsuarioCodigo) ?? 'Usuario';
  }

  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'US';
    }

    final first = parts.first.substring(0, 1).toUpperCase();
    final second = parts.length > 1
        ? parts.last.substring(0, 1).toUpperCase()
        : first;
    return '$first$second';
  }

  bool hasPermission(String permission) {
    return permisos.contains(permission);
  }

  factory AuthUser.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    final empresa = map['empresa'] is Map<String, dynamic>
        ? map['empresa'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return AuthUser(
      id: (map['id'] as num?)?.toInt() ?? 0,
      empresaId:
          (map['empresaId'] as num?)?.toInt() ??
          (empresa['id'] as num?)?.toInt(),
      empresaNombre:
          _firstText(map, const ['empresaNombre', 'nombreEmpresa']) ??
          _firstText(empresa, const ['nombre', 'razonSocial']),
      empresaNombreComercial:
          _firstText(map, const [
            'empresaNombreComercial',
            'nombreComercial',
            'empresaComercial',
          ]) ??
          _firstText(empresa, const ['nombreComercial', 'nombreCorto']),
      username: map['username']?.toString() ?? '',
      email: _cleanText(map['email']?.toString()),
      nombreCompleto: _cleanText(map['nombreCompleto']?.toString()),
      tipoUsuarioCodigo: map['tipoUsuarioCodigo']?.toString() ?? '',
      roles: (map['roles'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      permisos: (map['permisos'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  static String? _firstText(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = _cleanText(map[key]?.toString());
      if (value != null) {
        return value;
      }
    }

    return null;
  }

  static String? _cleanText(String? value) {
    final clean = value?.trim();
    if (clean == null || clean.isEmpty) {
      return null;
    }

    return clean;
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

class AppConfig {
  const AppConfig._();

  static const appName = 'NeoCloud Mobile';
  static const appSubtitle = 'Plataforma movil de facturacion electronica';
}

enum AppEnvironment {
  local,
  staging,
  production;

  static AppEnvironment fromName(String value) {
    return switch (value.toLowerCase()) {
      'production' || 'prod' => AppEnvironment.production,
      'staging' || 'stage' || 'test' => AppEnvironment.staging,
      _ => AppEnvironment.local,
    };
  }
}

class ApiEnvironment {
  const ApiEnvironment._();

  static const _environmentName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'local',
  );

  static const _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static AppEnvironment get current =>
      AppEnvironment.fromName(_environmentName);

  static String get baseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _normalize(_apiBaseUrlOverride);
    }

    return switch (current) {
      AppEnvironment.local => 'https://localhost:7043',
      AppEnvironment.staging => 'https://staging.neostp.com',
      AppEnvironment.production => 'https://api.neostp.com',
    };
  }

  static String _normalize(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}

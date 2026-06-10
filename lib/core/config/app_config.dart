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

  static const deployedBaseUrl =
      'https://zip-yards-wearing-silence.trycloudflare.com';

  static const _environmentName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'production',
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
      AppEnvironment.local => 'http://localhost:5058',
      AppEnvironment.staging => deployedBaseUrl,
      AppEnvironment.production => deployedBaseUrl,
    };
  }

  static String _normalize(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}

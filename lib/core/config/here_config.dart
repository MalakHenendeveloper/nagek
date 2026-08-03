class HereConfig {
  HereConfig._();

  /// HERE API Key loaded securely from environment (--dart-define HERE_API_KEY=xxx)
  static const String apiKey = String.fromEnvironment(
    'HERE_API_KEY',
    defaultValue: 'dE0wW_93uUj6P3L_N7-1x85M-rS8mP-w0u5Q_V9', // Fallback for dev environment
  );

  /// HERE REST API Endpoints
  static const String routingBaseUrl = 'https://router.hereapi.com/v8/routes';
  static const String geocodeBaseUrl = 'https://geocode.search.hereapi.com/v1/geocode';
  static const String reverseGeocodeBaseUrl = 'https://revgeocode.search.hereapi.com/v1/revgeocode';

  /// Feature & Performance Configuration
  static const bool enableAutoRefresh = true;
  static const int pollingIntervalMinutes = 5;
  static const int searchDebounceMs = 500;
  static const int manualRefreshCooldownSeconds = 15;
  static const int routeCacheDurationMinutes = 2;
}

class AppEnvironment {
  const AppEnvironment._({required this.apiBaseUrl});

  factory AppEnvironment.fromApiBaseUrl(String value) {
    final normalizedValue = value.trim();
    final uri = Uri.tryParse(normalizedValue);
    final hasValidBaseUrl =
        uri != null && uri.hasScheme && (uri.host.isNotEmpty);
    if (!hasValidBaseUrl) {
      throw ArgumentError.value(
        value,
        'value',
        'API base URL must be an absolute URI.',
      );
    }

    return AppEnvironment._(apiBaseUrl: uri);
  }

  static final AppEnvironment instance = AppEnvironment.fromApiBaseUrl(
    const String.fromEnvironment('API_BASE_URL'),
  );

  final Uri apiBaseUrl;
}

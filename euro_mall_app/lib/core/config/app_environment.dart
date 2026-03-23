/// Staging / production API base URL.
///
/// Default points to **staging**. Override for other environments:
/// ```bash
/// flutter run --dart-define=API_BASE_URL=https://other-host.example.com/api/v1
/// ```
///
/// VS Code `launch.json`: add to the configuration:
/// `"toolArgs": ["--dart-define=API_BASE_URL=https://..."]`
class AppEnvironment {
  AppEnvironment._();

  static const String _defaultStaging =
      'https://euromall.josequal.net/api/v1';

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultStaging,
  );

  /// True when a non-default URL was passed at compile time.
  static bool get hasCustomApi => apiBaseUrl != _defaultStaging;
}

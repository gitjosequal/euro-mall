import '../localization/app_localizations.dart';
import 'api_exception.dart';

/// User-facing text for API failures (avoid raw Dio messages).
String apiErrorUserMessage(AppLocalizations l10n, Object? error) {
  if (error is ApiException) {
    final code = error.statusCode;
    if (code == 404) {
      return l10n.tr('api_not_found');
    }
    if (code == 401 || code == 403) {
      return l10n.tr('sign_in_required');
    }
  }
  return l10n.tr('load_error');
}

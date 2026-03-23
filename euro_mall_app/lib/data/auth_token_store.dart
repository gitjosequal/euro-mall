import 'package:shared_preferences/shared_preferences.dart';

/// Persists the bearer token returned by the auth API.
class AuthTokenStore {
  AuthTokenStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'euromall_auth_token';

  String? get token {
    final t = _prefs.getString(_key);
    if (t == null || t.isEmpty) return null;
    return t;
  }

  Future<void> setToken(String? value) async {
    if (value == null || value.isEmpty) {
      await _prefs.remove(_key);
    } else {
      await _prefs.setString(_key, value);
    }
  }
}

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../api/api_models.dart';

String _localeQuery(String localeCode) =>
    localeCode == 'ar' ? 'ar' : 'en';

class AppConfigRepository {
  AppConfigRepository(this._client);

  final ApiClient _client;

  Future<AppRemoteConfig> fetchConfig(String localeCode) async {
    final json = await _client.getJson('/app/config');
    return AppRemoteConfig.parse(
      json,
      localeCode: _localeQuery(localeCode),
    );
  }
}

class CmsRepository {
  CmsRepository(this._client);

  final ApiClient _client;

  Future<CmsPageContent> fetchPage(String slug, String localeCode) async {
    final json = await _client.getJson(
      '/cms/pages/$slug',
      queryParameters: {'locale': _localeQuery(localeCode)},
    );
    return CmsPageContent.fromJson(json);
  }
}

class FaqRepository {
  FaqRepository(this._client);

  final ApiClient _client;

  Future<List<FaqItem>> fetchFaqs(String localeCode) async {
    final json = await _client.getJson(
      '/faqs',
      queryParameters: {'locale': _localeQuery(localeCode)},
    );
    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => FaqItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}

class ContactRepository {
  ContactRepository(this._client);

  final ApiClient _client;

  Future<void> submit({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    await _client.postJson(
      '/contact',
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'message': message,
      },
    );
  }
}

class UserRepository {
  UserRepository(this._client);

  final ApiClient _client;

  /// Returns null if not authenticated (401).
  Future<UserMe?> fetchMe() async {
    try {
      final json = await _client.getJson('/me');
      return UserMe.fromJson(json);
    } on ApiException catch (e) {
      if (e.statusCode == 401) return null;
      rethrow;
    }
  }

  Future<UserMe> updateMe({
    required String name,
    required String email,
    required String gender,
    DateTime? dob,
  }) async {
    final json = await _client.putJson(
      '/me',
      data: {
        'name': name,
        'email': email,
        'gender': gender,
        if (dob != null) 'dob': dob.toIso8601String().split('T').first,
      },
    );
    return UserMe.fromJson(json);
  }
}

class NotificationPreferencesRepository {
  NotificationPreferencesRepository(this._client);

  final ApiClient _client;

  Future<NotificationPreferences> fetch(String localeCode) async {
    final json = await _client.getJson(
      '/me/notification-preferences',
      queryParameters: {'locale': _localeQuery(localeCode)},
    );
    return NotificationPreferences.fromJson(json);
  }

  Future<NotificationPreferences> update(NotificationPreferences prefs) async {
    final json = await _client.putJson(
      '/me/notification-preferences',
      data: prefs.toJson(),
    );
    return NotificationPreferences.fromJson(json);
  }
}

class OrderHistoryRepository {
  OrderHistoryRepository(this._client);

  final ApiClient _client;

  /// Loyalty ledger rows + customer orders, newest first; includes currency for formatting.
  Future<MemberActivityResult> fetchMemberActivity(String localeCode) async {
    final json = await _client.getJson(
      '/orders',
      queryParameters: {'locale': _localeQuery(localeCode)},
    );
    final list = json['data'] as List<dynamic>? ?? [];
    final meta = json['meta'] is Map
        ? Map<String, dynamic>.from(json['meta'] as Map)
        : <String, dynamic>{};
    return MemberActivityResult(
      items: list
          .map(
            (e) =>
                OrderHistoryItem.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      currencySymbol:
          meta['currency_symbol']?.toString().trim().isNotEmpty == true
              ? meta['currency_symbol'].toString().trim()
              : 'JD',
      currencyCode: meta['currency_code']?.toString().trim().isNotEmpty == true
          ? meta['currency_code'].toString().trim()
          : 'JOD',
    );
  }
}

class PointsSchemaRepository {
  PointsSchemaRepository(this._client);

  final ApiClient _client;

  Future<PointsSchemaContent> fetchSchema(String localeCode) async {
    final json = await _client.getJson(
      '/points/schema',
      queryParameters: {'locale': _localeQuery(localeCode)},
    );
    return PointsSchemaContent.fromJson(json);
  }
}

class DeviceTokenRepository {
  DeviceTokenRepository(this._client);

  final ApiClient _client;

  Future<void> register({
    required String fcmToken,
    required String platform,
  }) async {
    await _client.postJson(
      '/devices/token',
      data: {
        'fcm_token': fcmToken,
        'platform': platform,
      },
    );
  }

  Future<void> unregister(String fcmToken) async {
    await _client.deleteJson(
      '/devices/token',
      data: {'fcm_token': fcmToken},
    );
  }
}

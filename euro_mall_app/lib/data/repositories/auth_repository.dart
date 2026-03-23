import '../../core/api/api_client.dart';

class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  /// Stub on server — wire SMS later. Required before OTP screen in some flows.
  Future<void> requestOtp(String phone) async {
    await _client.postJson(
      'auth/otp/send',
      data: {'phone': phone},
    );
  }

  /// Returns Sanctum plain-text token. Server checks cache from [requestOtp],
  /// or (dev) `AUTH_OTP_FALLBACK_FIXED` + `AUTH_OTP_CODE` (default **1111**).
  Future<String> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final json = await _client.postJson(
      'auth/otp/verify',
      data: {
        'phone': phone,
        'code': code,
      },
    );
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid auth response');
    }
    final token = data['token']?.toString() ?? '';
    if (token.isEmpty) {
      throw StateError('Missing token');
    }
    return token;
  }
}

import '../../core/api/api_client.dart';
import '../../core/models/models.dart';
import '../api/dashboard_models.dart';

/// Home dashboard + catalog (vouchers, offers, branches) from API.
class LoyaltyContentRepository {
  LoyaltyContentRepository(this._client);

  final ApiClient _client;

  String _lc(String localeCode) => localeCode == 'ar' ? 'ar' : 'en';

  Future<DashboardSnapshot> fetchDashboard(String localeCode) async {
    final json = await _client.getJson(
      'home/dashboard',
      queryParameters: {'locale': _lc(localeCode)},
    );
    return DashboardSnapshot.fromJson(json);
  }

  Future<List<Voucher>> fetchVouchers(String localeCode) async {
    final json = await _client.getJson(
      'vouchers',
      queryParameters: {'locale': _lc(localeCode)},
    );
    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => Voucher.fromApiJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Voucher> fetchVoucher(String id, String localeCode) async {
    final json = await _client.getJson(
      'vouchers/$id',
      queryParameters: {'locale': _lc(localeCode)},
    );
    final raw = json['data'];
    if (raw is! Map<String, dynamic>) {
      throw StateError('Invalid voucher');
    }
    return Voucher.fromApiJson(raw);
  }

  Future<List<Offer>> fetchOffers(String localeCode) async {
    final json = await _client.getJson(
      'offers',
      queryParameters: {'locale': _lc(localeCode)},
    );
    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => Offer.fromApiJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<Branch>> fetchBranches(String localeCode) async {
    final json = await _client.getJson(
      'branches',
      queryParameters: {'locale': _lc(localeCode)},
    );
    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => Branch.fromApiJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Requires Bearer token (member). Throws [ApiException] on 401/409/422.
  Future<void> redeemVoucher(String id) async {
    await _client.postJson('vouchers/$id/redeem');
  }
}

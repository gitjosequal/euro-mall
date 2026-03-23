VoucherStatus voucherStatusForExpiry(DateTime expiresAt) {
  final now = DateTime.now();
  if (expiresAt.isBefore(now)) return VoucherStatus.expired;
  if (expiresAt.difference(now).inDays <= 3) return VoucherStatus.soon;
  return VoucherStatus.active;
}

class TierInfo {
  final String name;
  final int currentPoints;
  final int nextTierPoints;
  final double progress;

  const TierInfo({
    required this.name,
    required this.currentPoints,
    required this.nextTierPoints,
    required this.progress,
  });
}

class WalletTransaction {
  final String id;
  final String title;
  final DateTime date;
  final double amount;
  final int points;
  final bool earned;

  const WalletTransaction({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.points,
    required this.earned,
  });
}

enum VoucherStatus { active, expired, soon }

class Voucher {
  final String id;
  final String title;
  final String description;
  final bool percentage;
  final double value;
  final DateTime expiresAt;
  final VoucherStatus status;
  final String code;
  final double? minimumSpend;
  /// Set when the logged-in user has redeemed this catalog voucher (API).
  final DateTime? redeemedAt;

  const Voucher({
    required this.id,
    required this.title,
    required this.description,
    required this.percentage,
    required this.value,
    required this.expiresAt,
    required this.status,
    required this.code,
    this.minimumSpend,
    this.redeemedAt,
  });

  bool get isRedeemed => redeemedAt != null;

  /// Payload for POS / in-mall scanners (id + human code).
  String get qrPayload => 'euromall|v=$id|${code.trim()}';

  factory Voucher.fromApiJson(Map<String, dynamic> json) {
    final expires = DateTime.tryParse(json['expires_at']?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final redeemedRaw = json['redeemed_at']?.toString();
    return Voucher(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      percentage: json['percentage'] == true,
      value: (json['value'] is num)
          ? (json['value'] as num).toDouble()
          : double.tryParse(json['value']?.toString() ?? '0') ?? 0,
      expiresAt: expires,
      status: voucherStatusForExpiry(expires),
      code: json['code']?.toString() ?? '',
      minimumSpend: json['minimum_spend'] != null
          ? (json['minimum_spend'] is num
              ? (json['minimum_spend'] as num).toDouble()
              : double.tryParse(json['minimum_spend'].toString()))
          : null,
      redeemedAt: redeemedRaw != null && redeemedRaw.isNotEmpty
          ? DateTime.tryParse(redeemedRaw)
          : null,
    );
  }
}

class Offer {
  final String id;
  final String title;
  final String subtitle;
  final String badge;
  final String? imageUrl;
  final DateTime? expiresAt;

  const Offer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    this.imageUrl,
    this.expiresAt,
  });

  factory Offer.fromApiJson(Map<String, dynamic> json) {
    final expStr = json['expires_at']?.toString();
    return Offer(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      badge: json['badge']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      expiresAt: expStr != null && expStr.isNotEmpty
          ? DateTime.tryParse(expStr)
          : null,
    );
  }
}

class Branch {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String hours;
  final double latitude;
  final double longitude;
  final bool openNow;

  const Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.hours,
    required this.latitude,
    required this.longitude,
    required this.openNow,
  });

  factory Branch.fromApiJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      hours: json['hours']?.toString() ?? '',
      latitude: (json['latitude'] is num)
          ? (json['latitude'] as num).toDouble()
          : double.tryParse(json['latitude']?.toString() ?? '0') ?? 0,
      longitude: (json['longitude'] is num)
          ? (json['longitude'] as num).toDouble()
          : double.tryParse(json['longitude']?.toString() ?? '0') ?? 0,
      openNow: json['open_now'] == true,
    );
  }
}

class UserProfile {
  final String name;
  final String phone;
  final String email;
  final String gender;
  final DateTime dob;

  const UserProfile({
    required this.name,
    required this.phone,
    required this.email,
    required this.gender,
    required this.dob,
  });
}

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
  });
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

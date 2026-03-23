import '../../core/models/models.dart';

class DashboardSnapshot {
  DashboardSnapshot({
    required this.guest,
    this.displayName,
    this.tierName,
    required this.currentPoints,
    required this.nextTierPoints,
    required this.tierProgress,
    required this.pointsToday,
    required this.activeVouchersCount,
    required this.recentTransactions,
  });

  final bool guest;
  final String? displayName;
  final String? tierName;
  final int currentPoints;
  final int nextTierPoints;
  final double tierProgress;
  final int pointsToday;
  final int activeVouchersCount;
  final List<WalletTransaction> recentTransactions;

  TierInfo get tier => TierInfo(
        name: tierName ?? '',
        currentPoints: currentPoints,
        nextTierPoints: nextTierPoints == 0 ? 4000 : nextTierPoints,
        progress: tierProgress.clamp(0.0, 1.0),
      );

  factory DashboardSnapshot.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final txs = (raw['recent_transactions'] as List<dynamic>? ?? [])
        .map(
          (e) => _walletTxnFromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
    return DashboardSnapshot(
      guest: raw['guest'] == true,
      displayName: raw['display_name']?.toString(),
      tierName: raw['tier_name']?.toString(),
      currentPoints: (raw['current_points'] is int)
          ? raw['current_points'] as int
          : int.tryParse(raw['current_points']?.toString() ?? '0') ?? 0,
      nextTierPoints: (raw['next_tier_points'] is int)
          ? raw['next_tier_points'] as int
          : int.tryParse(raw['next_tier_points']?.toString() ?? '4000') ?? 4000,
      tierProgress: (raw['tier_progress'] is num)
          ? (raw['tier_progress'] as num).toDouble()
          : double.tryParse(raw['tier_progress']?.toString() ?? '0') ?? 0,
      pointsToday: (raw['points_today'] is int)
          ? raw['points_today'] as int
          : int.tryParse(raw['points_today']?.toString() ?? '0') ?? 0,
      activeVouchersCount: (raw['active_vouchers_count'] is int)
          ? raw['active_vouchers_count'] as int
          : int.tryParse(raw['active_vouchers_count']?.toString() ?? '0') ?? 0,
      recentTransactions: txs,
    );
  }
}

WalletTransaction _walletTxnFromJson(Map<String, dynamic> json) {
  return WalletTransaction(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    date: DateTime.tryParse(json['date']?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    amount: (json['amount'] is num)
        ? (json['amount'] as num).toDouble()
        : double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
    points: (json['points'] is int)
        ? json['points'] as int
        : int.tryParse(json['points']?.toString() ?? '0') ?? 0,
    earned: json['earned'] == true,
  );
}

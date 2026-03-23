import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/ui_components.dart';
import '../../data/api/dashboard_models.dart';
import '../../data/repositories/loyalty_content_repository.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<DashboardSnapshot>? _future;

  Future<DashboardSnapshot> _load() {
    final lc = Localizations.localeOf(context).languageCode;
    return context.read<LoyaltyContentRepository>().fetchDashboard(lc);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyFormat = NumberFormat.currency(
      symbol: 'JD ',
      decimalDigits: 2,
    );
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<DashboardSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.tr('load_error'),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _retry,
                      child: Text(l10n.tr('retry')),
                    ),
                  ],
                ),
              ),
            );
          }
          final dash = snapshot.data!;
          final tier = dash.tier;
          final transactions = dash.recentTransactions;
          final displayName =
              dash.displayName?.isNotEmpty == true
                  ? dash.displayName!
                  : l10n.tr('guest_welcome');
          final ptsToday =
              dash.pointsToday >= 0 ? '+${dash.pointsToday}' : '${dash.pointsToday}';

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.tr('welcome'),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayName,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.tr('offers_headline'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 0,
                        shadowColor: Colors.black.withValues(alpha: 0.06),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.notifications_outlined,
                              color: AppColors.textPrimary,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: kAppPagePadding.copyWith(top: 8, bottom: 16),
                  child: _QuickActionsRow(l10n: l10n),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: kAppPagePadding,
                  child: _PointsHero(
                    points: tier.currentPoints,
                    tier: tier,
                    l10n: l10n,
                    onViewVouchers: () => context.go('/vouchers'),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: kAppPagePadding.copyWith(top: 8, bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: l10n.tr('points_today'),
                          value: ptsToday,
                          subtitle: l10n.tr('earned'),
                          icon: Icons.bolt_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: l10n.tr('vouchers'),
                          value:
                              '${dash.activeVouchersCount} ${l10n.tr('active')}',
                          subtitle: l10n.tr('redeem_now'),
                          icon: Icons.qr_code_rounded,
                          onTap: () => context.go('/vouchers'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: kAppPagePadding.copyWith(top: 8),
                  child: SectionHeader(
                    title: l10n.tr('recent_transactions'),
                    actionLabel: l10n.tr('view_all'),
                    onActionTap: () => context.go('/history'),
                  ),
                ),
              ),
              if (transactions.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: kAppPagePadding.copyWith(top: 8, bottom: 100),
                    child: Text(
                      l10n.tr('no_history'),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: kAppPagePadding.copyWith(top: 8, bottom: 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final t = transactions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TransactionTile(
                            transaction: t,
                            currencyFormat: currencyFormat,
                            l10n: l10n,
                          ),
                        );
                      },
                      childCount: transactions.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickChip(
            icon: Icons.local_offer_rounded,
            label: l10n.tr('offers'),
            color: AppColors.primary,
            onTap: () => context.push('/offers'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickChip(
            icon: Icons.qr_code_2_rounded,
            label: l10n.tr('vouchers'),
            color: AppColors.info,
            onTap: () => context.go('/vouchers'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickChip(
            icon: Icons.storefront_rounded,
            label: l10n.tr('branches'),
            color: AppColors.success,
            onTap: () => context.go('/branches'),
          ),
        ),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PointsHero extends StatelessWidget {
  const _PointsHero({
    required this.points,
    required this.tier,
    required this.l10n,
    required this.onViewVouchers,
  });

  final int points;
  final TierInfo tier;
  final AppLocalizations l10n;
  final VoidCallback onViewVouchers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = tier.nextTierPoints - tier.currentPoints;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.tr('points_balance'),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      points.toString(),
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onViewVouchers,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.qr_code_rounded, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      l10n.tr('vouchers'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoPill(
                label:
                    '${l10n.tr('tier_level')}: ${tier.name.isEmpty ? '—' : tier.name}',
                color: Colors.white,
                icon: Icons.star_rounded,
              ),
              InfoPill(
                label:
                    '$remaining ${l10n.tr('points_balance')} ${l10n.tr('to')} ${l10n.tr('tier_gold')}',
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: tier.progress,
              minHeight: 8,
              color: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.28),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.tr('progress_next_tier'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.currencyFormat,
    required this.l10n,
  });

  final WalletTransaction transaction;
  final NumberFormat currencyFormat;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEarned = transaction.earned;
    final pointsLabel = '${isEarned ? '+' : ''}${transaction.points}';
    final dateLabel = DateFormat('dd MMM, h:mm a').format(transaction.date);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.8)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isEarned
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isEarned
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: isEarned ? AppColors.success : AppColors.warning,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    pointsLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currencyFormat.format(transaction.amount),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

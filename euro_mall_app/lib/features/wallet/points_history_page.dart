import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../data/api/api_models.dart';
import '../../data/repositories/api_repositories.dart';

class PointsHistoryPage extends StatefulWidget {
  const PointsHistoryPage({super.key});

  @override
  State<PointsHistoryPage> createState() => _PointsHistoryPageState();
}

class _PointsHistoryPageState extends State<PointsHistoryPage> {
  Future<MemberActivityResult>? _future;

  Future<MemberActivityResult> _load() {
    final lc = Localizations.localeOf(context).languageCode;
    return context.read<OrderHistoryRepository>().fetchMemberActivity(lc);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<void> _pullRefresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  static WalletTransaction _toWallet(OrderHistoryItem o) {
    return WalletTransaction(
      id: o.id,
      title: o.title,
      date: o.date,
      amount: o.amount,
      points: o.points,
      earned: o.earned,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppPrimaryAppBar(title: l10n.tr('points_history')),
      body: FutureBuilder<MemberActivityResult>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final err = snapshot.error;
            if (err is ApiException && err.statusCode == 401) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.tr('sign_in_required'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () => context.push('/auth/phone'),
                        child: Text(l10n.tr('sign_in_cta')),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.tr('load_error')),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => setState(() => _future = _load()),
                      child: Text(l10n.tr('retry')),
                    ),
                  ],
                ),
              ),
            );
          }
          final bundle = snapshot.data!;
          final items = bundle.items;
          if (items.isEmpty) {
            return Center(child: Text(l10n.tr('no_history')));
          }
          final currencyFormat = NumberFormat.currency(
            name: bundle.currencyCode,
            symbol: '${bundle.currencySymbol} ',
            decimalDigits: 2,
          );
          final transactions = items.map(_toWallet).toList();
          return RefreshIndicator(
            onRefresh: _pullRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemBuilder: (context, index) {
                final txn = transactions[index];
                return _HistoryTile(
                  transaction: txn,
                  currencyFormat: currencyFormat,
                  l10n: l10n,
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemCount: transactions.length,
            ),
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
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
    final pointsLabel =
        '${isEarned ? '+' : '-'}${transaction.points} ${l10n.tr('points_unit')}';
    final dateLabel = DateFormat(
      'dd MMM yyyy, h:mm a',
    ).format(transaction.date);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.85)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
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
                  shape: BoxShape.circle,
                  color: isEarned
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.warning.withValues(alpha: 0.12),
                ),
                child: Icon(
                  isEarned ? Icons.call_made : Icons.call_received,
                  color: isEarned ? AppColors.success : AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
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

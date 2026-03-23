import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../data/mock_data.dart';

class PointsHistoryPage extends StatelessWidget {
  const PointsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final transactions = MockData.recentTransactions;
    final currencyFormat = NumberFormat.currency(
      symbol: 'JD ',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppPrimaryAppBar(title: l10n.tr('points_history')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemBuilder: (context, index) {
          final txn = transactions[index];
          return _HistoryTile(transaction: txn, currencyFormat: currencyFormat);
        },
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemCount: transactions.length,
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.transaction, required this.currencyFormat});

  final WalletTransaction transaction;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEarned = transaction.earned;
    final pointsLabel = '${isEarned ? '+' : ''}${transaction.points} pts';
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

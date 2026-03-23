import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/ui_components.dart';
import '../../data/mock_data.dart';

class VouchersPage extends StatelessWidget {
  const VouchersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('dd MMM');
    final vouchers = MockData.vouchers;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppPrimaryAppBar(title: l10n.tr('vouchers')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemBuilder: (context, index) {
          final voucher = vouchers[index];
          return _VoucherCard(
            voucher: voucher,
            dateFormat: dateFormat,
            l10n: l10n,
            onTap: () => context.go('/vouchers/${voucher.id}'),
          );
        },
        separatorBuilder: (_, index) => const SizedBox(height: 14),
        itemCount: vouchers.length,
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  const _VoucherCard({
    required this.voucher,
    required this.dateFormat,
    required this.l10n,
    required this.onTap,
  });

  final Voucher voucher;
  final DateFormat dateFormat;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color badgeColor = switch (voucher.status) {
      VoucherStatus.active => AppColors.success,
      VoucherStatus.soon => AppColors.warning,
      VoucherStatus.expired => AppColors.textSecondary,
    };
    final String badgeLabel = switch (voucher.status) {
      VoucherStatus.active => l10n.tr('active'),
      VoucherStatus.soon => l10n.tr('soon_expiring'),
      VoucherStatus.expired => l10n.tr('expired'),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.85),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  voucher.percentage
                      ? '${voucher.value.toStringAsFixed(0)}%'
                      : 'JD ${voucher.value.toStringAsFixed(0)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            voucher.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        InfoPill(label: badgeLabel, color: badgeColor),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      voucher.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.tr('expires')}: ${dateFormat.format(voucher.expiresAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

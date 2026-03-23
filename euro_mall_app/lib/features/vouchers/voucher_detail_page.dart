import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/ui_components.dart';
import '../../data/mock_data.dart';

class VoucherDetailPage extends StatelessWidget {
  const VoucherDetailPage({super.key, required this.voucherId});

  final String voucherId;

  @override
  Widget build(BuildContext context) {
    final voucher = MockData.vouchers.firstWhere(
      (v) => v.id == voucherId,
      orElse: () => MockData.vouchers.first,
    );
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppPrimaryAppBar(
        title: l10n.tr('voucher_details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/vouchers');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              voucher.title,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              voucher.description,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            InfoPill(label: badgeLabel, color: badgeColor),
                          ],
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          voucher.percentage
                              ? '${voucher.value.toStringAsFixed(0)}%'
                              : 'JD ${voucher.value.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${l10n.tr('expires')}: ${dateFormat.format(voucher.expiresAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (voucher.minimumSpend != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      '${l10n.tr('minimum_spend')}: JD ${voucher.minimumSpend!.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 10,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.qr_code_2_rounded,
                      size: 120,
                      color: AppColors.primary,
                    ),
                    Text(
                      voucher.code,
                      style: const TextStyle(
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.tr('qr_for_redeem'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: voucher.status == VoucherStatus.expired
                    ? null
                    : () {},
                child: Text(l10n.tr('redeem_now')),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.tr('terms'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.tr('terms_text'),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

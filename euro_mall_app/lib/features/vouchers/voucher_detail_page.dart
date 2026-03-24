import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/api/api_exception.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/ui_components.dart';
import '../../data/auth_token_store.dart';
import '../../data/repositories/loyalty_content_repository.dart';

class VoucherDetailPage extends StatefulWidget {
  const VoucherDetailPage({super.key, required this.voucherId});

  final String voucherId;

  @override
  State<VoucherDetailPage> createState() => _VoucherDetailPageState();
}

class _VoucherDetailPageState extends State<VoucherDetailPage> {
  Future<Voucher>? _future;
  bool _redeeming = false;

  Future<Voucher> _load() {
    final lc = Localizations.localeOf(context).languageCode;
    return context
        .read<LoyaltyContentRepository>()
        .fetchVoucher(widget.voucherId, lc);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<void> _redeem(BuildContext context, AppLocalizations l10n) async {
    final token = context.read<AuthTokenStore>().token;
    if (token == null || token.isEmpty) {
      await context.push('/auth/phone');
      return;
    }
    setState(() => _redeeming = true);
    try {
      await context.read<LoyaltyContentRepository>().redeemVoucher(
            widget.voucherId,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tr('redeem_success'))),
      );
      setState(() => _future = _load());
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _redeeming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');

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
      body: FutureBuilder<Voucher>(
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
          final voucher = snapshot.data!;
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

          return SingleChildScrollView(
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  voucher.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    InfoPill(label: badgeLabel, color: badgeColor),
                                    if (voucher.isRedeemed)
                                      InfoPill(
                                        label: l10n.tr('redeemed'),
                                        color: AppColors.textSecondary,
                                      ),
                                  ],
                                ),
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
                    width: 240,
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      children: [
                        QrImageView(
                          data: voucher.qrPayload,
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: AppColors.primary,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          voucher.code,
                          style: const TextStyle(
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        BarcodeWidget(
                          barcode: Barcode.code128(),
                          data: voucher.code,
                          width: 180,
                          height: 50,
                          drawText: false,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.tr('qr_for_redeem'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
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
                        : voucher.isRedeemed
                            ? null
                            : _redeeming
                                ? null
                                : () => _redeem(context, l10n),
                    child: _redeeming
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            voucher.isRedeemed
                                ? l10n.tr('redeemed')
                                : l10n.tr('redeem_now'),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.push('/settings/terms'),
                  child: Text(l10n.tr('settings_terms')),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

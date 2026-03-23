import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../data/api/api_models.dart';
import '../../data/repositories/api_repositories.dart';
import 'widgets/settings_api_widgets.dart';

class SettingsOrderHistoryPage extends StatefulWidget {
  const SettingsOrderHistoryPage({super.key});

  @override
  State<SettingsOrderHistoryPage> createState() =>
      _SettingsOrderHistoryPageState();
}

class _SettingsOrderHistoryPageState extends State<SettingsOrderHistoryPage> {
  late Future<List<OrderHistoryItem>> _future;
  bool _deps = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_deps) return;
    _deps = true;
    _future = context.read<OrderHistoryRepository>().fetchOrders();
  }

  void _retry() {
    setState(() {
      _future = context.read<OrderHistoryRepository>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppPrimaryAppBar(title: l10n.tr('settings_order_history')),
      body: FutureBuilder<List<OrderHistoryItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final err = snapshot.error;
            if (err is ApiException && err.statusCode == 401) {
              return _SignInRequired(
                onSignIn: () => context.push('/auth/phone'),
              );
            }
            return SettingsRetryBody(
              message: l10n.tr('load_error'),
              onRetry: _retry,
            );
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return Center(child: Text(l10n.tr('orders_empty')));
          }
          final currencyFormat = NumberFormat.currency(
            symbol: 'JD ',
            decimalDigits: 2,
          );
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _OrderTile(
                item: list[index],
                currencyFormat: currencyFormat,
              );
            },
          );
        },
      ),
    );
  }
}

class _SignInRequired extends StatelessWidget {
  const _SignInRequired({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              onPressed: onSignIn,
              child: Text(l10n.tr('sign_in_cta')),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({
    required this.item,
    required this.currencyFormat,
  });

  final OrderHistoryItem item;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEarned = item.earned;
    final pointsLabel = '${isEarned ? '+' : ''}${item.points} pts';
    final dateLabel = DateFormat('dd MMM yyyy, h:mm a').format(item.date);

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
                      item.title,
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
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isEarned ? AppColors.success : AppColors.warning,
                    ),
                  ),
                  Text(
                    currencyFormat.format(item.amount),
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

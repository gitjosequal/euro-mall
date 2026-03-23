import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/ui_components.dart';
import '../../data/mock_data.dart';

class BranchesPage extends StatelessWidget {
  const BranchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final branches = MockData.branches;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppPrimaryAppBar(title: l10n.tr('branches')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemBuilder: (context, index) {
          if (index == 0) return _MapPreview(l10n: l10n);
          final branch = branches[index - 1];
          return _BranchCard(branch: branch, l10n: l10n);
        },
        separatorBuilder: (_, i) =>
            i == 0 ? const SizedBox(height: 18) : const SizedBox(height: 14),
        itemCount: branches.length + 1,
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFF8F9FB), Color(0xFFEFF4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_rounded, size: 48, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              l10n.tr('map_view'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              l10n.tr('map_placeholder'),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.branch, required this.l10n});

  final Branch branch;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.85)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    branch.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                InfoPill(
                  label: branch.openNow ? l10n.tr('open') : l10n.tr('closed'),
                  color: branch.openNow
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    branch.address,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(branch.phone, style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${l10n.tr('working_hours')}: ${branch.hours}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.navigation_rounded),
                  label: Text(l10n.tr('map_view')),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call),
                  label: Text(l10n.tr('contact')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

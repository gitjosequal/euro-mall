import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/maps/open_maps.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/ui_components.dart';
import '../../data/repositories/loyalty_content_repository.dart';

(double, double) _centroid(List<Branch> branches) {
  if (branches.isEmpty) return (31.9539, 35.9106);
  double lat = 0, lng = 0;
  var n = 0;
  for (final b in branches) {
    if (b.latitude != 0 || b.longitude != 0) {
      lat += b.latitude;
      lng += b.longitude;
      n++;
    }
  }
  if (n == 0) return (31.9539, 35.9106);
  return (lat / n, lng / n);
}

class BranchesPage extends StatefulWidget {
  const BranchesPage({super.key});

  @override
  State<BranchesPage> createState() => _BranchesPageState();
}

class _BranchesPageState extends State<BranchesPage> {
  Future<List<Branch>>? _future;

  Future<List<Branch>> _load() {
    final lc = Localizations.localeOf(context).languageCode;
    return context.read<LoyaltyContentRepository>().fetchBranches(lc);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppPrimaryAppBar(title: l10n.tr('branches')),
      body: FutureBuilder<List<Branch>>(
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
          final branches = snapshot.data ?? [];
          if (branches.isEmpty) {
            return Center(child: Text(l10n.tr('no_history')));
          }
          final (mapLat, mapLng) = _centroid(branches);
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _MapPreview(
                  l10n: l10n,
                  latitude: mapLat,
                  longitude: mapLng,
                );
              }
              final branch = branches[index - 1];
              return _BranchCard(branch: branch, l10n: l10n);
            },
            separatorBuilder: (_, i) =>
                i == 0 ? const SizedBox(height: 18) : const SizedBox(height: 14),
            itemCount: branches.length + 1,
          );
        },
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({
    required this.l10n,
    required this.latitude,
    required this.longitude,
  });

  final AppLocalizations l10n;
  final double latitude;
  final double longitude;

  Future<void> _open(BuildContext context) async {
    final ok = await openMapsLatLng(latitude, longitude);
    if (context.mounted && !ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tr('maps_open_failed'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
                  l10n.tr('tap_to_open_maps'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.branch, required this.l10n});

  final Branch branch;
  final AppLocalizations l10n;

  Future<void> _openMaps(BuildContext context) async {
    final ok = await openMapsLatLng(branch.latitude, branch.longitude);
    if (context.mounted && !ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tr('maps_open_failed'))),
      );
    }
  }

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
            Text(
              branch.address,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  branch.phone,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    branch.hours,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            if (branch.latitude != 0 || branch.longitude != 0) ...[
              const SizedBox(height: 14),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => _openMaps(context),
                  icon: const Icon(Icons.directions_rounded, size: 20),
                  label: Text(l10n.tr('directions')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _locationToIndex(location);
    final l10n = AppLocalizations.of(context);

    final items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: l10n.tr('dashboard'),
        route: '/dashboard',
      ),
      _NavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        label: l10n.tr('points_history'),
        route: '/history',
      ),
      _NavItem(
        icon: Icons.qr_code_2_outlined,
        activeIcon: Icons.qr_code_scanner_rounded,
        label: l10n.tr('vouchers'),
        route: '/vouchers',
      ),
      _NavItem(
        icon: Icons.store_mall_directory_outlined,
        activeIcon: Icons.store_mall_directory_rounded,
        label: l10n.tr('branches'),
        route: '/branches',
      ),
      _NavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
        label: l10n.tr('settings'),
        route: '/profile',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: child),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Material(
          elevation: 0,
          color: AppColors.background,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(
                  color: AppColors.divider.withValues(alpha: 0.9),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  offset: const Offset(0, -2),
                  blurRadius: 8,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              children: List.generate(items.length, (i) {
                final item = items[i];
                final selected = index == i;
                return Expanded(
                  child: _NavButton(
                    item: item,
                    selected: selected,
                    onTap: () => _onNavTap(context, i),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  int _locationToIndex(String location) {
    if (location.startsWith('/history')) return 1;
    if (location.startsWith('/vouchers')) return 2;
    if (location.startsWith('/branches')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/history');
        break;
      case 2:
        context.go('/vouchers');
        break;
      case 3:
        context.go('/branches');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                selected ? item.activeIcon : item.icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                height: 1.1,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

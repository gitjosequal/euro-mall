import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Horizontal padding for main scroll/list content.
const EdgeInsets kAppPagePadding = EdgeInsets.symmetric(horizontal: 20);

/// Consistent app bar for tab / list screens (title left, optional actions, hairline bottom).
class AppPrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppPrimaryAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      leading: leading,
      titleSpacing: leading != null ? null : 20,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.45,
        ),
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.divider.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

/// Section title above grouped content (uppercase optional feel via letter-spacing).
class AppSectionLabel extends StatelessWidget {
  const AppSectionLabel(this.text, {super.key, this.padding});

  final String text;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.15,
        ),
      ),
    );
  }
}

/// White rounded surface for forms (login, register).
class AppElevatedSurface extends StatelessWidget {
  const AppElevatedSurface({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        boxShadow: AppDimens.shadowElevated,
        border: Border.all(
          color: AppColors.outlineSubtle.withValues(alpha: 0.9),
        ),
      ),
      child: child,
    );
  }
}

/// Decorative top gradient strip (auth / marketing).
class AppAuthHeaderBand extends StatelessWidget {
  const AppAuthHeaderBand({super.key, this.height = 140});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.background,
            AppColors.info.withValues(alpha: 0.06),
          ],
        ),
      ),
    );
  }
}

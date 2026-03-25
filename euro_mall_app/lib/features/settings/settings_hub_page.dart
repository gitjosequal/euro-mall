import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../data/api/api_models.dart';
import '../../data/auth_token_store.dart';
import '../../data/repositories/api_repositories.dart';
import '../../main.dart';
import '../../core/widgets/app_scaffold.dart';

class SettingsHubPage extends StatefulWidget {
  const SettingsHubPage({super.key});

  @override
  State<SettingsHubPage> createState() => _SettingsHubPageState();
}

class _SettingsHubPageState extends State<SettingsHubPage> {
  Future<UserMe?>? _userFuture;
  Future<AppRemoteConfig>? _configFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userFuture ??= context.read<UserRepository>().fetchMe();
    _configFuture ??= context.read<AppConfigRepository>().fetchConfig(
          Localizations.localeOf(context).languageCode,
        );
  }

  void _reloadUser() {
    setState(() {
      _userFuture = context.read<UserRepository>().fetchMe();
    });
  }

  Future<void> _logout() async {
    final devices = context.read<DeviceTokenRepository>();
    final auth = context.read<AuthTokenStore>();
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await devices.unregister(token);
      }
    } catch (_) {}
    await auth.setToken(null);
    if (mounted) context.go('/auth/phone');
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final appState = AppStateScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -44,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.background,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.12,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 52)),
          SliverToBoxAdapter(
            child: FutureBuilder<UserMe?>(
              future: _userFuture,
              builder: (context, snap) {
                final user = snap.hasError ? null : snap.data;
                final name = user?.name.isNotEmpty == true
                    ? user!.name
                    : l10n.tr('guest_welcome');
                final phone = user?.phone ?? '';
                final tier = user?.tierName;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      if (phone.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          phone,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (tier != null && tier.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.workspace_premium_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${l10n.tr('tier_level')}: $tier',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
              child: AppSectionLabel(l10n.tr('settings')),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: kAppPagePadding,
              child: AppElevatedSurface(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.person_outline_rounded,
                      label: l10n.tr('settings_my_profile'),
                      onTap: () => context.push('/settings/my-profile')
                          .then((_) => _reloadUser()),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.article_outlined,
                      label: l10n.tr('settings_terms'),
                      onTap: () => context.push('/settings/terms'),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      label: l10n.tr('settings_privacy'),
                      onTap: () => context.push('/settings/privacy'),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.receipt_long_outlined,
                      label: l10n.tr('settings_order_history'),
                      onTap: () => context.push('/settings/orders'),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.stars_outlined,
                      label: l10n.tr('settings_points_schema'),
                      onTap: () => context.push('/settings/points-schema'),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      label: l10n.tr('settings_notifications'),
                      onTap: () => context.push('/settings/notifications'),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      label: l10n.tr('settings_about'),
                      onTap: () => context.push('/settings/about'),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.support_agent_outlined,
                      label: l10n.tr('settings_contact'),
                      onTap: () => context.push('/settings/contact'),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.help_outline_rounded,
                      label: l10n.tr('settings_faqs'),
                      onTap: () => context.push('/settings/faqs'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: AppSectionLabel(l10n.tr('app_preferences')),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: kAppPagePadding,
              child: AppElevatedSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.tr('language'),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ListenableBuilder(
                      listenable: appState,
                      builder: (context, _) {
                        return SegmentedButton<Locale>(
                          segments: [
                            ButtonSegment(
                              value: const Locale('en'),
                              label: Text(l10n.tr('english')),
                              icon: const Icon(Icons.language, size: 18),
                            ),
                            ButtonSegment(
                              value: const Locale('ar'),
                              label: Text(l10n.tr('arabic')),
                              icon: const Icon(Icons.translate_rounded, size: 18),
                            ),
                          ],
                          selected: {appState.locale},
                          onSelectionChanged: (set) {
                            appState.setLocale(set.first);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.tr('language_settings_hint'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: OutlinedButton.icon(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: Text(
                  l10n.tr('logout'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, pkgSnap) {
                return FutureBuilder<AppRemoteConfig>(
                  future: _configFuture,
                  builder: (context, cfgSnap) {
                    final pkg = pkgSnap.data;
                    final cfg = cfgSnap.data;
                    final version = pkg != null
                        ? (cfg?.displayVersion?.isNotEmpty == true
                            ? cfg!.displayVersion!
                            : pkg.version)
                        : '';
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                      child: Column(
                        children: [
                          if (version.isNotEmpty)
                            Text(
                              '${l10n.tr('app_version_label')} $version',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          if (cfg?.developerName != null &&
                              cfg!.developerName!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            TextButton(
                              onPressed: () =>
                                  _launchUrl(cfg.developerUrl),
                              child: Text(cfg.developerName!),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

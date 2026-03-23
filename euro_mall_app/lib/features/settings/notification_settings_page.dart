import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../data/api/api_models.dart';
import '../../data/repositories/api_repositories.dart';
import 'widgets/settings_api_widgets.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  Future<NotificationPreferences>? _future;
  bool _saving = false;

  Future<NotificationPreferences> _fetch() {
    final lc = Localizations.localeOf(context).languageCode;
    return context.read<NotificationPreferencesRepository>().fetch(lc);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _fetch();
  }

  Future<void> _update(NotificationPreferences next) async {
    setState(() => _saving = true);
    try {
      await context.read<NotificationPreferencesRepository>().update(next);
      if (mounted) {
        setState(() {
          _future = Future.value(next);
          _saving = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        if (e.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).tr('sign_in_required')),
            ),
          );
          context.push('/auth/phone');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppPrimaryAppBar(title: l10n.tr('settings_notifications')),
      body: FutureBuilder<NotificationPreferences>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final err = snapshot.error;
            if (err is ApiException && err.statusCode == 401) {
              return _SignInRequiredBody(
                message: l10n.tr('sign_in_required'),
                onSignIn: () => context.push('/auth/phone'),
              );
            }
            return SettingsRetryBody(
              message: l10n.tr('load_error'),
              onRetry: () => setState(() => _future = _fetch()),
            );
          }
          final p = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              if (_saving)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              SwitchListTile.adaptive(
                value: p.pushMarketing,
                onChanged: _saving
                    ? null
                    : (v) => _update(
                          NotificationPreferences(
                            pushMarketing: v,
                            pushOrders: p.pushOrders,
                            emailDigest: p.emailDigest,
                          ),
                        ),
                title: Text(l10n.tr('notifications')),
                subtitle: Text(l10n.tr('notif_marketing_hint')),
              ),
              SwitchListTile.adaptive(
                value: p.pushOrders,
                onChanged: _saving
                    ? null
                    : (v) => _update(
                          NotificationPreferences(
                            pushMarketing: p.pushMarketing,
                            pushOrders: v,
                            emailDigest: p.emailDigest,
                          ),
                        ),
                title: Text(l10n.tr('notif_orders_title')),
                subtitle: Text(l10n.tr('notif_orders_hint')),
              ),
              SwitchListTile.adaptive(
                value: p.emailDigest,
                onChanged: _saving
                    ? null
                    : (v) => _update(
                          NotificationPreferences(
                            pushMarketing: p.pushMarketing,
                            pushOrders: p.pushOrders,
                            emailDigest: v,
                          ),
                        ),
                title: Text(l10n.tr('email')),
                subtitle: Text(l10n.tr('notif_email_hint')),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SignInRequiredBody extends StatelessWidget {
  const _SignInRequiredBody({
    required this.message,
    required this.onSignIn,
  });

  final String message;
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
            Text(message, textAlign: TextAlign.center),
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

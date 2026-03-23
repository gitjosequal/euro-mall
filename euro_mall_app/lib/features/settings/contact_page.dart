import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../data/api/api_models.dart';
import '../../data/repositories/api_repositories.dart';
import 'widgets/settings_api_widgets.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _submitting = false;

  Future<AppRemoteConfig>? _configFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configFuture ??= context.read<AppConfigRepository>().fetchConfig();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchTel(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'\s'), '');
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      await context.read<ContactRepository>().submit(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            message: _messageCtrl.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).tr('message_sent'))),
        );
        _messageCtrl.clear();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).tr('load_error')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppPrimaryAppBar(title: l10n.tr('settings_contact')),
      body: FutureBuilder<AppRemoteConfig>(
        future: _configFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return SettingsRetryBody(
              message: l10n.tr('load_error'),
              onRetry: () => setState(() {
                _configFuture = context.read<AppConfigRepository>().fetchConfig();
              }),
            );
          }
          final cfg = snap.data!;

          return FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, pkgSnap) {
              final pkg = pkgSnap.data;
              final versionLine = pkg != null
                  ? '${l10n.tr('app_version_label')} ${cfg.displayVersion?.isNotEmpty == true ? cfg.displayVersion : pkg.version}'
                  : null;

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  if (cfg.supportPhone != null &&
                      cfg.supportPhone!.isNotEmpty) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.phone_in_talk_outlined),
                      title: Text(cfg.supportPhone!),
                      trailing: TextButton(
                        onPressed: () => _launchTel(cfg.supportPhone!),
                        child: Text(l10n.tr('call_support')),
                      ),
                    ),
                    const Divider(),
                  ],
                  if (cfg.socialLinks.isNotEmpty) ...[
                    Text(
                      l10n.tr('contact'),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cfg.socialLinks
                          .map(
                            (l) => ActionChip(
                              label: Text(l.label),
                              onPressed: () => _launchUrl(l.url),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    l10n.tr('send_message'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.tr('full_name'),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? l10n.tr('field_required')
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: l10n.tr('email'),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return l10n.tr('field_required');
                            }
                            if (!v.contains('@')) {
                              return l10n.tr('invalid_email');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: l10n.tr('your_phone'),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? l10n.tr('field_required')
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _messageCtrl,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: l10n.tr('contact_message'),
                            alignLabelWithHint: true,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? l10n.tr('field_required')
                              : null,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 48,
                          child: FilledButton(
                            onPressed: _submitting ? null : _submit,
                            child: Text(l10n.tr('send_message')),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (versionLine != null)
                    Text(
                      versionLine,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  if (cfg.developerName != null &&
                      cfg.developerName!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: cfg.developerUrl != null &&
                              cfg.developerUrl!.isNotEmpty
                          ? () => _launchUrl(cfg.developerUrl!)
                          : null,
                      child: Text(cfg.developerName!),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

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

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  Future<UserMe?>? _loadFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFuture ??= context.read<UserRepository>().fetchMe();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppPrimaryAppBar(title: l10n.tr('settings_my_profile')),
      body: FutureBuilder<UserMe?>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return SettingsRetryBody(
              message: l10n.tr('load_error'),
              onRetry: () => setState(() {
                _loadFuture = context.read<UserRepository>().fetchMe();
              }),
            );
          }
          final me = snapshot.data;
          if (me == null) {
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
                      onPressed: () => context.push('/auth/phone'),
                      child: Text(l10n.tr('sign_in_cta')),
                    ),
                  ],
                ),
              ),
            );
          }
          return _EditableProfileForm(user: me);
        },
      ),
    );
  }
}

class _EditableProfileForm extends StatefulWidget {
  const _EditableProfileForm({required this.user});

  final UserMe user;

  @override
  State<_EditableProfileForm> createState() => _EditableProfileFormState();
}

class _EditableProfileFormState extends State<_EditableProfileForm> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late String _gender;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameCtrl = TextEditingController(text: u.name);
    _emailCtrl = TextEditingController(text: u.email);
    _gender = u.gender.isNotEmpty ? u.gender : 'other';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = context.read<UserRepository>();
    try {
      await repo.updateMe(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            gender: _gender,
            dob: widget.user.dob,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).tr('save_changes')),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        if (e.statusCode == 401) {
          context.push('/auth/phone');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message.isNotEmpty ? e.message : l10n.tr('load_error'))),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final u = widget.user;
    final dobStr = u.dob != null
        ? DateFormat.yMd(l10n.locale.toString()).format(u.dob!)
        : '—';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        if (_saving) const LinearProgressIndicator(minHeight: 2),
        TextField(
          controller: _nameCtrl,
          decoration: InputDecoration(
            labelText: l10n.tr('full_name'),
            prefixIcon: const Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: l10n.tr('phone_hint'),
            prefixIcon: const Icon(Icons.phone_outlined),
            hintText: u.phone,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: l10n.tr('email'),
            prefixIcon: const Icon(Icons.mail_outline_rounded),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          key: ValueKey(_gender),
          initialValue: _gender,
          decoration: InputDecoration(
            labelText: l10n.tr('gender'),
            prefixIcon: const Icon(Icons.people_outline_rounded),
          ),
          items: [
            DropdownMenuItem(value: 'male', child: Text(l10n.tr('male'))),
            DropdownMenuItem(value: 'female', child: Text(l10n.tr('female'))),
            DropdownMenuItem(value: 'other', child: Text(l10n.tr('other'))),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _gender = v);
          },
        ),
        const SizedBox(height: 16),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: l10n.tr('dob'),
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            hintText: dobStr,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 50,
          child: FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              l10n.tr('save_changes'),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.tr('language_settings_hint'),
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

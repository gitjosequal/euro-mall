import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../data/mock_data.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late String _gender;

  @override
  void initState() {
    super.initState();
    _gender = MockData.profile.gender;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = MockData.profile;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.tr('complete_profile'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tr('lets_personalize'),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.tr('phone_verified'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            AppElevatedSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: l10n.tr('full_name'),
                      prefixIcon: const Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
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
                      DropdownMenuItem(
                        value: 'male',
                        child: Text(l10n.tr('male')),
                      ),
                      DropdownMenuItem(
                        value: 'female',
                        child: Text(l10n.tr('female')),
                      ),
                      DropdownMenuItem(
                        value: 'other',
                        child: Text(l10n.tr('other')),
                      ),
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
                      hintText:
                          '${profile.dob.day}/${profile.dob.month}/${profile.dob.year}',
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: () => context.go('/dashboard'),
                child: Text(
                  l10n.tr('submit'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

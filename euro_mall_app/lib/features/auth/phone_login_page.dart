import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../data/repositories/auth_repository.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final CountryService _countryService = CountryService();
  late Country _country;
  final _phoneCtrl = TextEditingController();
  final _phoneFocus = FocusNode();
  bool _loading = false;
  bool _phoneFocused = false;

  @override
  void initState() {
    super.initState();
    _country = _countryService.findByCode('JO') ?? _countryService.getAll().first;
    _phoneFocus.addListener(() {
      final f = _phoneFocus.hasFocus;
      if (_phoneFocused != f) setState(() => _phoneFocused = f);
    });
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  String get _e164 {
    final digits = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    return '+${_country.phoneCode}$digits';
  }

  Future<void> _continue() async {
    final l10n = AppLocalizations.of(context);
    final digits = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tr('phone_required'))),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<AuthRepository>().requestOtp(_e164);
      if (!mounted) return;
      context.push('/auth/otp', extra: _e164);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openCountryPicker() {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      showSearch: true,
      useSafeArea: true,
      favorite: const ['JO'],
      countryListTheme: CountryListThemeData(
        flagSize: 28,
        backgroundColor: AppColors.surface,
        textStyle: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        searchTextStyle: theme.textTheme.bodyLarge,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        bottomSheetHeight: mq.size.height * 0.88,
        inputDecoration: InputDecoration(
          hintText: 'Search country or dial code',
          prefixIcon: const Icon(Icons.search_rounded),
          filled: true,
          fillColor: AppColors.surfaceMuted,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.outlineSubtle.withValues(alpha: 0.95),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
      onSelect: (Country c) {
        setState(() => _country = c);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final borderColor = _phoneFocused
        ? AppColors.primary
        : AppColors.outlineSubtle.withValues(alpha: 0.95);
    final borderWidth = _phoneFocused ? 2.0 : 1.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    boxShadow: AppDimens.shadowSoft,
                    border: Border.all(
                      color: AppColors.outlineSubtle.withValues(alpha: 0.85),
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/euro_mall_logo.jpeg',
                    height: 56,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.tr('phone_login_title'),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.tr('login_subtitle'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 36),
              AppElevatedSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.tr('sign_in'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.tr('mobile_number'),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: borderColor,
                          width: borderWidth,
                        ),
                      ),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _openCountryPicker,
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(13),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    14,
                                    10,
                                    14,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _country.flagEmoji,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '+${_country.phoneCode}',
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down_rounded,
                                        color: AppColors.textSecondary,
                                        size: 26,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 28,
                              color: AppColors.divider.withValues(alpha: 0.9),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _phoneCtrl,
                                focusNode: _phoneFocus,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _continue(),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: l10n.tr('phone_hint'),
                                  hintStyle: theme.textTheme.bodyLarge
                                      ?.copyWith(
                                    color: AppColors.textTertiary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _loading ? null : _continue,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                l10n.tr('continue'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => context.go('/dashboard'),
                child: Text(
                  l10n.tr('browse_as_guest'),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

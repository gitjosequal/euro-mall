import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;

  List<_Slide> _slides(AppLocalizations l10n) => [
    _Slide(
      title: l10n.tr('onboard_title_1'),
      body: l10n.tr('onboard_body_1'),
      icon: Icons.star_rounded,
    ),
    _Slide(
      title: l10n.tr('onboard_title_2'),
      body: l10n.tr('onboard_body_2'),
      icon: Icons.qr_code_2_rounded,
    ),
    _Slide(
      title: l10n.tr('onboard_title_3'),
      body: l10n.tr('onboard_body_3'),
      icon: Icons.location_on_rounded,
    ),
  ];

  void _next(AppLocalizations l10n) {
    final slides = _slides(l10n);
    if (_index == slides.length - 1) {
      context.go('/auth/phone');
    } else {
      _controller.nextPage(
        duration: AppDimens.animMedium,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slides = _slides(l10n);
    final progress = (_index + 1) / slides.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: AppColors.divider,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => context.go('/auth/phone'),
                    child: Text(l10n.tr('skip')),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemCount: slides.length,
                  itemBuilder: (_, i) => _OnboardSlide(slide: slides[i]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  slides.length,
                  (i) => AnimatedContainer(
                    duration: AppDimens.animFast,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _index == i ? 26 : 8,
                    decoration: BoxDecoration(
                      color: _index == i
                          ? AppColors.primary
                          : AppColors.divider,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: () => _next(l10n),
                  child: Text(
                    _index == slides.length - 1
                        ? l10n.tr('start_now')
                        : l10n.tr('next'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide {
  final String title;
  final String body;
  final IconData icon;
  _Slide({required this.title, required this.body, required this.icon});
}

class _OnboardSlide extends StatelessWidget {
  const _OnboardSlide({required this.slide});

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            boxShadow: AppDimens.shadowSoft,
            border: Border.all(
              color: AppColors.outlineSubtle.withValues(alpha: 0.9),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(slide.icon, size: 64, color: AppColors.primary),
              ),
              const SizedBox(height: 28),
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                slide.body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

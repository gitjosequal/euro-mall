import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../data/api/api_models.dart';
import '../../data/repositories/api_repositories.dart';
import 'widgets/settings_api_widgets.dart';

class FaqsPage extends StatefulWidget {
  const FaqsPage({super.key});

  @override
  State<FaqsPage> createState() => _FaqsPageState();
}

class _FaqsPageState extends State<FaqsPage> {
  Future<List<FaqItem>>? _future;
  String? _localeLoaded;

  void _ensureFuture({bool force = false}) {
    final lc = Localizations.localeOf(context).languageCode;
    if (!force && _localeLoaded == lc && _future != null) return;
    _localeLoaded = lc;
    _future = context.read<FaqRepository>().fetchFaqs(lc);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _ensureFuture();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppPrimaryAppBar(title: l10n.tr('settings_faqs')),
      body: FutureBuilder<List<FaqItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return SettingsRetryBody(
              message: l10n.tr('load_error'),
              onRetry: () => setState(() => _ensureFuture(force: true)),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(child: Text(l10n.tr('no_faqs')));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final f = items[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      title: Text(
                        f.question,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            f.answer,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

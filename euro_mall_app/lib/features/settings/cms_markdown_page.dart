import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../data/api/api_models.dart';
import '../../data/repositories/api_repositories.dart';
import 'widgets/settings_api_widgets.dart';

class CmsMarkdownPage extends StatefulWidget {
  const CmsMarkdownPage({
    super.key,
    required this.slug,
    required this.title,
  });

  final String slug;
  final String title;

  @override
  State<CmsMarkdownPage> createState() => _CmsMarkdownPageState();
}

class _CmsMarkdownPageState extends State<CmsMarkdownPage> {
  Future<CmsPageContent>? _future;
  String? _localeLoaded;

  void _ensureFuture({bool force = false}) {
    final lc = Localizations.localeOf(context).languageCode;
    if (!force && _localeLoaded == lc && _future != null) return;
    _localeLoaded = lc;
    _future = context.read<CmsRepository>().fetchPage(widget.slug, lc);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _ensureFuture();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppPrimaryAppBar(title: widget.title),
      body: FutureBuilder<CmsPageContent>(
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
          final page = snapshot.data!;
          if (page.bodyMarkdown.isEmpty) {
            return Center(child: Text(l10n.tr('no_content')));
          }
          return Markdown(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            data: page.bodyMarkdown,
            selectable: true,
          );
        },
      ),
    );
  }
}

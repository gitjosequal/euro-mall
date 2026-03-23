import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../../data/auth_token_store.dart';
import '../../data/repositories/api_repositories.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/loyalty_content_repository.dart';

/// Registers API client and repositories for the subtree.
class AppRepositoryProviders extends StatelessWidget {
  const AppRepositoryProviders({
    super.key,
    required this.prefs,
    required this.child,
  });

  final SharedPreferences prefs;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthTokenStore>(
          create: (_) => AuthTokenStore(prefs),
        ),
        ProxyProvider<AuthTokenStore, ApiClient>(
          update: (context, auth, previous) => ApiClient(auth: auth),
        ),
        ProxyProvider<ApiClient, AppConfigRepository>(
          update: (context, client, previous) => AppConfigRepository(client),
        ),
        ProxyProvider<ApiClient, CmsRepository>(
          update: (context, client, previous) => CmsRepository(client),
        ),
        ProxyProvider<ApiClient, FaqRepository>(
          update: (context, client, previous) => FaqRepository(client),
        ),
        ProxyProvider<ApiClient, ContactRepository>(
          update: (context, client, previous) => ContactRepository(client),
        ),
        ProxyProvider<ApiClient, UserRepository>(
          update: (context, client, previous) => UserRepository(client),
        ),
        ProxyProvider<ApiClient, NotificationPreferencesRepository>(
          update: (context, client, previous) =>
              NotificationPreferencesRepository(client),
        ),
        ProxyProvider<ApiClient, OrderHistoryRepository>(
          update: (context, client, previous) => OrderHistoryRepository(client),
        ),
        ProxyProvider<ApiClient, PointsSchemaRepository>(
          update: (context, client, previous) => PointsSchemaRepository(client),
        ),
        ProxyProvider<ApiClient, AuthRepository>(
          update: (context, client, previous) => AuthRepository(client),
        ),
        ProxyProvider<ApiClient, LoyaltyContentRepository>(
          update: (context, client, previous) =>
              LoyaltyContentRepository(client),
        ),
      ],
      child: child,
    );
  }
}

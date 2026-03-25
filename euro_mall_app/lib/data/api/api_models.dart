class SocialLink {
  const SocialLink({required this.label, required this.url, this.iconKey});

  final String label;
  final String url;
  final String? iconKey;

  factory SocialLink.fromJson(Map<String, dynamic> json) {
    return SocialLink(
      label: json['label']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      iconKey: json['icon']?.toString(),
    );
  }
}

/// Remote-driven onboarding slide (falls back to local l10n if [slides] empty).
class OnboardingSlideRemote {
  const OnboardingSlideRemote({
    required this.title,
    required this.body,
    required this.iconKey,
  });

  final String title;
  final String body;
  final String iconKey;

  factory OnboardingSlideRemote.fromJson(Map<String, dynamic> json) {
    return OnboardingSlideRemote(
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      iconKey: json['icon']?.toString() ?? 'star_rounded',
    );
  }
}

/// Public app metadata managed in the admin backend (no hardcoded marketing copy).
class AppRemoteConfig {
  const AppRemoteConfig({
    this.supportPhone,
    this.socialLinks = const [],
    this.developerName,
    this.developerUrl,
    this.displayVersion,
    this.currencySymbol = 'JD',
    this.currencyCode = 'JOD',
    this.onboardingSlides = const [],
  });

  final String? supportPhone;
  final List<SocialLink> socialLinks;
  final String? developerName;
  final String? developerUrl;
  final String? displayVersion;
  final String currencySymbol;
  final String currencyCode;
  final List<OnboardingSlideRemote> onboardingSlides;

  /// [localeCode] picks `title_en`/`title_ar` etc. for onboarding slides from the API.
  factory AppRemoteConfig.parse(
    Map<String, dynamic> json, {
    String localeCode = 'en',
  }) {
    final raw = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final links = (raw['social_links'] as List<dynamic>? ?? [])
        .map((e) => SocialLink.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((l) => l.url.isNotEmpty)
        .toList();
    final ar = localeCode == 'ar';
    final slideMaps = (raw['onboarding_slides'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map((m) {
          final title = ar
              ? (m['title_ar']?.toString() ?? m['title_en']?.toString() ?? '')
              : (m['title_en']?.toString() ?? m['title_ar']?.toString() ?? '');
          final body = ar
              ? (m['body_ar']?.toString() ?? m['body_en']?.toString() ?? '')
              : (m['body_en']?.toString() ?? m['body_ar']?.toString() ?? '');
          return OnboardingSlideRemote(
            title: title,
            body: body,
            iconKey: m['icon']?.toString() ?? 'star_rounded',
          );
        })
        .where((s) => s.title.isNotEmpty)
        .toList();
    return AppRemoteConfig(
      supportPhone: raw['support_phone']?.toString(),
      socialLinks: links,
      developerName: raw['developer_name']?.toString(),
      developerUrl: raw['developer_url']?.toString(),
      displayVersion: raw['display_version']?.toString(),
      currencySymbol: raw['currency_symbol']?.toString().trim().isNotEmpty == true
          ? raw['currency_symbol'].toString().trim()
          : 'JD',
      currencyCode: raw['currency_code']?.toString().trim().isNotEmpty == true
          ? raw['currency_code'].toString().trim()
          : 'JOD',
      onboardingSlides: slideMaps,
    );
  }
}

class CmsPageContent {
  const CmsPageContent({
    required this.slug,
    required this.title,
    required this.bodyMarkdown,
  });

  final String slug;
  final String title;
  final String bodyMarkdown;

  factory CmsPageContent.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return CmsPageContent(
      slug: raw['slug']?.toString() ?? '',
      title: raw['title']?.toString() ?? '',
      bodyMarkdown: raw['body']?.toString() ?? '',
    );
  }
}

class FaqItem {
  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
  });

  final String id;
  final String question;
  final String answer;

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
    );
  }
}

class UserMe {
  const UserMe({
    required this.name,
    required this.phone,
    required this.email,
    required this.gender,
    this.dob,
    this.tierName,
  });

  final String name;
  final String phone;
  final String email;
  final String gender;
  final DateTime? dob;
  final String? tierName;

  factory UserMe.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    DateTime? dob;
    final dobStr = raw['dob']?.toString();
    if (dobStr != null && dobStr.isNotEmpty) {
      dob = DateTime.tryParse(dobStr);
    }
    return UserMe(
      name: raw['name']?.toString() ?? '',
      phone: raw['phone']?.toString() ?? '',
      email: raw['email']?.toString() ?? '',
      gender: raw['gender']?.toString() ?? 'other',
      dob: dob,
      tierName: raw['tier_name']?.toString(),
    );
  }

}

class NotificationPreferences {
  const NotificationPreferences({
    required this.pushMarketing,
    required this.pushOrders,
    required this.emailDigest,
  });

  final bool pushMarketing;
  final bool pushOrders;
  final bool emailDigest;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return NotificationPreferences(
      pushMarketing: raw['push_marketing'] == true,
      pushOrders: raw['push_orders'] == true,
      emailDigest: raw['email_digest'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'push_marketing': pushMarketing,
        'push_orders': pushOrders,
        'email_digest': emailDigest,
      };
}

class OrderHistoryItem {
  const OrderHistoryItem({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.points,
    required this.earned,
  });

  final String id;
  final String title;
  final DateTime date;
  final double amount;
  final int points;
  final bool earned;

  factory OrderHistoryItem.fromJson(Map<String, dynamic> json) {
    return OrderHistoryItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      points: (json['points'] is int)
          ? json['points'] as int
          : int.tryParse(json['points']?.toString() ?? '0') ?? 0,
      earned: json['earned'] == true || json['type']?.toString() == 'earn',
    );
  }
}

/// `GET /orders` — unified ledger + orders with currency meta.
class MemberActivityResult {
  const MemberActivityResult({
    required this.items,
    required this.currencySymbol,
    required this.currencyCode,
  });

  final List<OrderHistoryItem> items;
  final String currencySymbol;
  final String currencyCode;
}

class PointsSchemaContent {
  const PointsSchemaContent({required this.bodyMarkdown});

  final String bodyMarkdown;

  factory PointsSchemaContent.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return PointsSchemaContent(
      bodyMarkdown: raw['body']?.toString() ?? '',
    );
  }
}

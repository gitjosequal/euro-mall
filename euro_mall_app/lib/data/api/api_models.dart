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

/// Public app metadata managed in the admin backend (no hardcoded marketing copy).
class AppRemoteConfig {
  const AppRemoteConfig({
    this.supportPhone,
    this.socialLinks = const [],
    this.developerName,
    this.developerUrl,
    this.displayVersion,
  });

  final String? supportPhone;
  final List<SocialLink> socialLinks;
  final String? developerName;
  final String? developerUrl;
  final String? displayVersion;

  factory AppRemoteConfig.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final links = (raw['social_links'] as List<dynamic>? ?? [])
        .map((e) => SocialLink.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((l) => l.url.isNotEmpty)
        .toList();
    return AppRemoteConfig(
      supportPhone: raw['support_phone']?.toString(),
      socialLinks: links,
      developerName: raw['developer_name']?.toString(),
      developerUrl: raw['developer_url']?.toString(),
      displayVersion: raw['display_version']?.toString(),
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

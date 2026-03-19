import 'package:owa_flutter/screens/seo_data.dart';

class FaqSpec {
  final int id;
  final int tenantId;
  final int sectionId;
  final String slug;
  final String status;
  final int schemaVersion;
  final FaqData data;
  final DateTime updatedAt;
  final DateTime publishedAt;

  FaqSpec({
    required this.id,
    required this.tenantId,
    required this.sectionId,
    required this.slug,
    required this.status,
    required this.schemaVersion,
    required this.data,
    required this.updatedAt,
    required this.publishedAt,
  });

  factory FaqSpec.fromMap(Map<String, dynamic> map) {
    return FaqSpec(
      id: map['id'] ?? 0,
      tenantId: map['tenant_id'] ?? 0,
      sectionId: map['section_id'] ?? 0,
      slug: map['slug'] ?? '',
      status: map['status'] ?? '',
      schemaVersion: map['schema_version'] ?? 0,
      data: FaqData.fromMap(map['data'] ?? {}),
      updatedAt: DateTime.parse(map['updated_at']),
      publishedAt: DateTime.parse(map['published_at']),
    );
  }
}

// ---------------------------------------------------------------------------
// FaqData
// ---------------------------------------------------------------------------

class FaqData {
  final SeoData seo;
  final List<FaqItem> faqs;
  final bool replace;
  final String pageTitle;
  final String pageDescription;

  FaqData({
    required this.seo,
    required this.faqs,
    required this.replace,
    required this.pageTitle,
    required this.pageDescription,
  });

  factory FaqData.fromMap(Map<String, dynamic> map) {
    return FaqData(
      seo: SeoData.fromMap(map['seo'] ?? {}),
      faqs:
          (map['faqs'] as List?)
              ?.map((item) => FaqItem.fromMap(item))
              .toList() ??
          [],
      replace: map['replace'] ?? false,
      pageTitle: map['pageTitle'] ?? '',
      pageDescription: map['pageDescription'] ?? '',
    );
  }
}

// ---------------------------------------------------------------------------
// FaqItem
// ---------------------------------------------------------------------------

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});

  factory FaqItem.fromMap(Map<String, dynamic> map) {
    return FaqItem(
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
    );
  }
}

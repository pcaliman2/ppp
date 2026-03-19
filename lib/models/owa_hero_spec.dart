// File: lib/models/owa_hero_spec.dart

import 'package:owa_flutter/models/seo_data.dart';

class OWAHeroSpec {
  final int id;
  final int tenantId;
  final int sectionId;
  final String slug;
  final String status;
  final int schemaVersion;
  final OWAHeroSpecData data;
  final DateTime updatedAt;
  final DateTime publishedAt;

  OWAHeroSpec({
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

  factory OWAHeroSpec.fromMap(Map<String, dynamic> map) {
    return OWAHeroSpec(
      id: map['id'] ?? 0,
      tenantId: map['tenant_id'] ?? 0,
      sectionId: map['section_id'] ?? 0,
      slug: map['slug'] ?? '',
      status: map['status'] ?? '',
      schemaVersion: map['schema_version'] ?? 0,
      data: OWAHeroSpecData.fromMap(map['data'] ?? {}),
      updatedAt: DateTime.parse(map['updated_at']),
      publishedAt: DateTime.parse(map['published_at']),
    );
  }
}

class OWAHeroSpecData {
  final SeoData seo;
  final String heroText;
  final OWAHeroSpecButton heroButton;
  final OWAHeroSpecImage heroBackgroundImage;

  OWAHeroSpecData({
    required this.seo,
    required this.heroText,
    required this.heroButton,
    required this.heroBackgroundImage,
  });

  factory OWAHeroSpecData.fromMap(Map<String, dynamic> map) {
    // Check if __draft exists and use it, otherwise use published data
    final draftData = map['__draft'];
    final sourceData =
        draftData != null && draftData is Map<String, dynamic>
            ? draftData
            : map;

    return OWAHeroSpecData(
      seo: SeoData.fromMap(sourceData['seo'] ?? {}),
      heroText: sourceData['heroText'] ?? '',
      heroButton: OWAHeroSpecButton.fromMap(sourceData['heroButton'] ?? {}),
      heroBackgroundImage: OWAHeroSpecImage.fromMap(
        sourceData['heroBackgroundImage'] ?? {},
      ),
    );
  }
}

class OWAHeroSpecButton {
  final String href;
  final String text;

  OWAHeroSpecButton({required this.href, required this.text});

  factory OWAHeroSpecButton.fromMap(Map<String, dynamic> map) {
    return OWAHeroSpecButton(href: map['href'] ?? '', text: map['text'] ?? '');
  }
}

class OWAHeroSpecImage {
  final String url;

  OWAHeroSpecImage({required this.url});

  factory OWAHeroSpecImage.fromMap(Map<String, dynamic> map) {
    return OWAHeroSpecImage(url: map['url'] ?? '');
  }
}

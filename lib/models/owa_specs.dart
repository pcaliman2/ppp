// File: lib/models/owa_specs.dart

import 'package:owa_flutter/models/image_data.dart';
import 'package:owa_flutter/screens/seo_data.dart';

// ─────────────────────────────────────────────
// HERO SECTION
// ─────────────────────────────────────────────

class OWAHeroSectionSpec {
  final int id;
  final int tenantId;
  final int sectionId;
  final String slug;
  final String status;
  final int schemaVersion;
  final OWAHeroSectionData data;
  final DateTime updatedAt;
  final DateTime publishedAt;

  OWAHeroSectionSpec({
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

  factory OWAHeroSectionSpec.fromMap(Map<String, dynamic> map) {
    return OWAHeroSectionSpec(
      id: map['id'] ?? 0,
      tenantId: map['tenant_id'] ?? 0,
      sectionId: map['section_id'] ?? 0,
      slug: map['slug'] ?? '',
      status: map['status'] ?? '',
      schemaVersion: map['schema_version'] ?? 0,
      data: OWAHeroSectionData.fromMap(map['data'] ?? {}),
      updatedAt: DateTime.parse(map['updated_at']),
      publishedAt: DateTime.parse(map['published_at']),
    );
  }
}

class OWAHeroSectionData {
  final SeoData seo;
  final String heroText;
  final OWAHeroButton heroButton;
  final ImageData heroBackgroundImage;

  OWAHeroSectionData({
    required this.seo,
    required this.heroText,
    required this.heroButton,
    required this.heroBackgroundImage,
  });

  factory OWAHeroSectionData.fromMap(Map<String, dynamic> map) {
    // Check if __draft exists and use it, otherwise use published data
    final draftData = map['__draft'];
    final sourceData =
        draftData != null && draftData is Map<String, dynamic>
            ? draftData
            : map;

    return OWAHeroSectionData(
      seo: SeoData.fromMap(sourceData['seo'] ?? {}),
      heroText: sourceData['heroText'] ?? '',
      heroButton: OWAHeroButton.fromMap(sourceData['heroButton'] ?? {}),
      heroBackgroundImage: ImageData.fromMap(
        sourceData['heroBackgroundImage'] ?? {},
      ),
    );
  }
}

class OWAHeroButton {
  final String href;
  final String text;

  OWAHeroButton({required this.href, required this.text});

  factory OWAHeroButton.fromMap(Map<String, dynamic> map) {
    return OWAHeroButton(href: map['href'] ?? '', text: map['text'] ?? '');
  }
}

// ─────────────────────────────────────────────
// MOTO TEXT SECTION
// ─────────────────────────────────────────────

class OWAMotoTextSpec {
  final int id;
  final int tenantId;
  final int sectionId;
  final String slug;
  final String status;
  final int schemaVersion;
  final OWAMotoTextData data;
  final DateTime updatedAt;
  final DateTime publishedAt;

  OWAMotoTextSpec({
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

  factory OWAMotoTextSpec.fromMap(Map<String, dynamic> map) {
    return OWAMotoTextSpec(
      id: map['id'] ?? 0,
      tenantId: map['tenant_id'] ?? 0,
      sectionId: map['section_id'] ?? 0,
      slug: map['slug'] ?? '',
      status: map['status'] ?? '',
      schemaVersion: map['schema_version'] ?? 0,
      data: OWAMotoTextData.fromMap(map['data'] ?? {}),
      updatedAt: DateTime.parse(map['updated_at']),
      publishedAt: DateTime.parse(map['published_at']),
    );
  }
}

class OWAMotoTextData {
  final String motoText;

  OWAMotoTextData({required this.motoText});

  factory OWAMotoTextData.fromMap(Map<String, dynamic> map) {
    return OWAMotoTextData(motoText: map['motoText'] ?? '');
  }
}

// ─────────────────────────────────────────────
// DISCOVER SECTION
// ─────────────────────────────────────────────

class OWADiscoverSectionSpec {
  final int id;
  final int tenantId;
  final int sectionId;
  final String slug;
  final String status;
  final int schemaVersion;
  final OWADiscoverSectionData data;
  final DateTime updatedAt;
  final DateTime publishedAt;

  OWADiscoverSectionSpec({
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

  factory OWADiscoverSectionSpec.fromMap(Map<String, dynamic> map) {
    return OWADiscoverSectionSpec(
      id: map['id'] ?? 0,
      tenantId: map['tenant_id'] ?? 0,
      sectionId: map['section_id'] ?? 0,
      slug: map['slug'] ?? '',
      status: map['status'] ?? '',
      schemaVersion: map['schema_version'] ?? 0,
      data: OWADiscoverSectionData.fromMap(map['data'] ?? {}),
      updatedAt: DateTime.parse(map['updated_at']),
      publishedAt: DateTime.parse(map['published_at']),
    );
  }
}

class OWADiscoverSectionData {
  final SeoData seo;
  final String pageTitle;
  final String pageDescription;
  final List<OWADiscoverCard> discoverSections;

  OWADiscoverSectionData({
    required this.seo,
    required this.pageTitle,
    required this.pageDescription,
    required this.discoverSections,
  });

  factory OWADiscoverSectionData.fromMap(Map<String, dynamic> map) {
    // Check if __draft exists and use it, otherwise use published data
    final draftData = map['__draft'];
    final sourceData =
        draftData != null && draftData is Map<String, dynamic>
            ? draftData
            : map;

    return OWADiscoverSectionData(
      seo: SeoData.fromMap(sourceData['seo'] ?? {}),
      pageTitle: sourceData['pageTitle'] ?? '',
      pageDescription: sourceData['pageDescription'] ?? '',
      discoverSections:
          (sourceData['discoverSections'] as List<dynamic>?)
              ?.map(
                (item) => OWADiscoverCard.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class OWADiscoverCard {
  final String cardTitle;
  final String cardDescription;
  final String cardLinkText;
  final String cardLinkUrl;
  final ImageData cardBackgroundImage;

  OWADiscoverCard({
    required this.cardTitle,
    required this.cardDescription,
    required this.cardLinkText,
    required this.cardLinkUrl,
    required this.cardBackgroundImage,
  });

  factory OWADiscoverCard.fromMap(Map<String, dynamic> map) {
    return OWADiscoverCard(
      cardTitle: map['cardTitle'] ?? '',
      cardDescription: map['cardDescription'] ?? '',
      cardLinkText: map['cardLinkText'] ?? '',
      cardLinkUrl: map['cardLinkUrl'] ?? '',
      cardBackgroundImage: ImageData.fromMap(map['cardBackgroundImage'] ?? {}),
    );
  }
}

// ─────────────────────────────────────────────
// THERAPIES SECTION
// ─────────────────────────────────────────────

class OWATherapiesSectionSpec {
  final int id;
  final int tenantId;
  final int sectionId;
  final String slug;
  final String status;
  final int schemaVersion;
  final OWATherapiesSectionData data;
  final DateTime updatedAt;
  final DateTime publishedAt;

  OWATherapiesSectionSpec({
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

  factory OWATherapiesSectionSpec.fromMap(Map<String, dynamic> map) {
    return OWATherapiesSectionSpec(
      id: map['id'] ?? 0,
      tenantId: map['tenant_id'] ?? 0,
      sectionId: map['section_id'] ?? 0,
      slug: map['slug'] ?? '',
      status: map['status'] ?? '',
      schemaVersion: map['schema_version'] ?? 0,
      data: OWATherapiesSectionData.fromMap(map['data'] ?? {}),
      updatedAt: DateTime.parse(map['updated_at']),
      publishedAt: DateTime.parse(map['published_at']),
    );
  }
}

class OWATherapiesSectionData {
  final SeoData seo;
  final String pageTitle;
  final String pageDescription;
  final OWABookButton bookButton;
  final List<OWATherapyItem> therapiesList;

  OWATherapiesSectionData({
    required this.seo,
    required this.pageTitle,
    required this.pageDescription,
    required this.bookButton,
    required this.therapiesList,
  });

  factory OWATherapiesSectionData.fromMap(Map<String, dynamic> map) {
    // Check if __draft exists and use it, otherwise use published data
    final draftData = map['__draft'];
    final sourceData =
        draftData != null && draftData is Map<String, dynamic>
            ? draftData
            : map;

    return OWATherapiesSectionData(
      seo: SeoData.fromMap(sourceData['seo'] ?? {}),
      pageTitle: sourceData['pageTitle'] ?? '',
      pageDescription: sourceData['pageDescription'] ?? '',
      bookButton: OWABookButton.fromMap(sourceData['bookButton'] ?? {}),
      therapiesList:
          (sourceData['therapiesList'] as List<dynamic>?)
              ?.map(
                (item) => OWATherapyItem.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class OWABookButton {
  final String url;
  final String text;

  OWABookButton({required this.url, required this.text});

  factory OWABookButton.fromMap(Map<String, dynamic> map) {
    return OWABookButton(url: map['url'] ?? '', text: map['text'] ?? '');
  }
}

class OWATherapyItem {
  final String therapyName;
  final String therapyDescription;
  final ImageData therapyImage;
  final List<String> benefits;

  OWATherapyItem({
    required this.therapyName,
    required this.therapyDescription,
    required this.therapyImage,
    required this.benefits,
  });

  static String _normalizeText(String value) {
    final lineNormalized = value
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\u2028', '\n')
        .replaceAll('\u2029', '\n');
    final trailingSpacesRemoved = lineNormalized.replaceAll(
      RegExp(r'[ \t]+\n'),
      '\n',
    );
    final collapsedBlankLines = trailingSpacesRemoved.replaceAll(
      RegExp(r'\n{3,}'),
      '\n\n',
    );
    return collapsedBlankLines.trim();
  }

  factory OWATherapyItem.fromMap(Map<String, dynamic> map) {
    return OWATherapyItem(
      therapyName: _normalizeText((map['therapyName'] ?? '').toString()),
      therapyDescription: _normalizeText(
        (map['therapyDescription'] ?? '').toString(),
      ),
      therapyImage: ImageData.fromMap(map['therapyImage'] ?? {}),
      benefits:
          (map['benefits'] as List<dynamic>?)
              ?.map((item) => _normalizeText(item.toString()))
              .where((item) => item.isNotEmpty)
              .toList() ??
          [],
    );
  }
}

class OWAMembershipsSectionSpec {
  final int id;
  final int tenantId;
  final int sectionId;
  final String slug;
  final String status;
  final int schemaVersion;
  final OWAMembershipsSectionData data;
  final DateTime updatedAt;
  final DateTime publishedAt;

  OWAMembershipsSectionSpec({
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

  factory OWAMembershipsSectionSpec.fromMap(Map<String, dynamic> map) {
    return OWAMembershipsSectionSpec(
      id: map['id'] ?? 0,
      tenantId: map['tenant_id'] ?? 0,
      sectionId: map['section_id'] ?? 0,
      slug: map['slug'] ?? '',
      status: map['status'] ?? '',
      schemaVersion: map['schema_version'] ?? 0,
      data: OWAMembershipsSectionData.fromMap(map['data'] ?? {}),
      updatedAt: DateTime.parse(map['updated_at']),
      publishedAt: DateTime.parse(map['published_at']),
    );
  }
}

class OWAMembershipsSectionData {
  final SeoData seo;
  final String pageTitle;
  final String pageDescription;
  final OWAMembershipsBookButton bookButton;
  final List<OWAMembershipItem> membershipsList;

  OWAMembershipsSectionData({
    required this.seo,
    required this.pageTitle,
    required this.pageDescription,
    required this.bookButton,
    required this.membershipsList,
  });

  factory OWAMembershipsSectionData.fromMap(Map<String, dynamic> map) {
    // Check if __draft exists and use it, otherwise use published data
    final draftData = map['__draft'];
    final sourceData =
        draftData != null && draftData is Map<String, dynamic>
            ? draftData
            : map;

    return OWAMembershipsSectionData(
      seo: SeoData.fromMap(sourceData['seo'] ?? {}),
      pageTitle: sourceData['pageTitle'] ?? '',
      pageDescription: sourceData['pageDescription'] ?? '',
      bookButton: OWAMembershipsBookButton.fromMap(
        sourceData['bookButton'] ?? {},
      ),
      membershipsList:
          (sourceData['membershipsList'] as List<dynamic>?)
              ?.map(
                (item) =>
                    OWAMembershipItem.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class OWAMembershipsBookButton {
  final String url;
  final String text;

  OWAMembershipsBookButton({required this.url, required this.text});

  factory OWAMembershipsBookButton.fromMap(Map<String, dynamic> map) {
    return OWAMembershipsBookButton(
      url: map['url'] ?? '',
      text: map['text'] ?? '',
    );
  }
}

class OWAMembershipItem {
  final String membershipTitle;
  final String description;
  final String price;
  final List<String> benefits;
  final ImageData backgroundImage;

  OWAMembershipItem({
    required this.membershipTitle,
    required this.description,
    required this.price,
    required this.benefits,
    required this.backgroundImage,
  });

  factory OWAMembershipItem.fromMap(Map<String, dynamic> map) {
    return OWAMembershipItem(
      membershipTitle: map['membershipTitle'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? '',
      benefits:
          (map['benefits'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      backgroundImage: ImageData.fromMap(map['backgroundImage'] ?? {}),
    );
  }
}

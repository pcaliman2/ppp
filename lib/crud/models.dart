// Main Page Structure
class PageSpec {
  final String pageId;
  final String state;
  final PageSnapshot snapshot;

  PageSpec({required this.pageId, required this.state, required this.snapshot});

  factory PageSpec.fromMap(Map<String, dynamic> map) {
    return PageSpec(
      pageId: map['page_id'] ?? '',
      state: map['state'] ?? '',
      snapshot: PageSnapshot.fromMap(map['snapshot'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {'page_id': pageId, 'state': state, 'snapshot': snapshot.toMap()};
  }
}

class PageSnapshot {
  final PageInfo page;
  final List<Section> sections;

  PageSnapshot({required this.page, required this.sections});

  factory PageSnapshot.fromMap(Map<String, dynamic> map) {
    return PageSnapshot(
      page: PageInfo.fromMap(map['page'] ?? {}),
      sections: List<Section>.from(
        (map['sections'] ?? []).map((x) => Section.fromMap(x)),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'page': page.toMap(),
      'sections': sections.map((x) => x.toMap()).toList(),
    };
  }
}

class PageInfo {
  final String id;
  final String slug;
  final String title;

  PageInfo({required this.id, required this.slug, required this.title});

  factory PageInfo.fromMap(Map<String, dynamic> map) {
    return PageInfo(
      id: map['id'] ?? '',
      slug: map['slug'] ?? '',
      title: map['title'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'slug': slug, 'title': title};
  }
}

// Section Base Class
class Section {
  final String id;
  final String type;
  final int position;
  final int schemaVersion;
  final Map<String, dynamic> data;

  Section({
    required this.id,
    required this.type,
    required this.position,
    required this.schemaVersion,
    required this.data,
  });

  factory Section.fromMap(Map<String, dynamic> map) {
    return Section(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      position: map['position'] ?? 0,
      schemaVersion: map['schema_version'] ?? 1,
      data: Map<String, dynamic>.from(map['data'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'position': position,
      'schema_version': schemaVersion,
      'data': data,
    };
  }
}

// Navigation Components
class NavBarData {
  final Brand brand;
  final List<NavLink> leftLinks;
  final List<NavLink> rightLinks;

  NavBarData({
    required this.brand,
    required this.leftLinks,
    required this.rightLinks,
  });

  factory NavBarData.fromMap(Map<String, dynamic> map) {
    return NavBarData(
      brand: Brand.fromMap(map['brand'] ?? {}),
      leftLinks: List<NavLink>.from(
        (map['leftLinks'] ?? []).map((x) => NavLink.fromMap(x)),
      ),
      rightLinks: List<NavLink>.from(
        (map['rightLinks'] ?? []).map((x) => NavLink.fromMap(x)),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brand': brand.toMap(),
      'leftLinks': leftLinks.map((x) => x.toMap()).toList(),
      'rightLinks': rightLinks.map((x) => x.toMap()).toList(),
    };
  }
}

class Brand {
  final String href;
  final String text;

  Brand({required this.href, required this.text});

  factory Brand.fromMap(Map<String, dynamic> map) {
    return Brand(href: map['href'] ?? '', text: map['text'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'href': href, 'text': text};
  }
}

class NavLink {
  final String href;
  final String label;
  final bool? external;

  NavLink({required this.href, required this.label, this.external});

  factory NavLink.fromMap(Map<String, dynamic> map) {
    return NavLink(
      href: map['href'] ?? '',
      label: map['label'] ?? '',
      external: map['external'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'href': href,
      'label': label,
      if (external != null) 'external': external,
    };
  }
}

// Hero Components
class HeroTwoUpData {
  final List<MediaItem> media;
  final Layout layout;
  final Overlay overlay;

  HeroTwoUpData({
    required this.media,
    required this.layout,
    required this.overlay,
  });

  factory HeroTwoUpData.fromMap(Map<String, dynamic> map) {
    return HeroTwoUpData(
      media: List<MediaItem>.from(
        (map['media'] ?? []).map((x) => MediaItem.fromMap(x)),
      ),
      layout: Layout.fromMap(map['layout'] ?? {}),
      overlay: Overlay.fromMap(map['overlay'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'media': media.map((x) => x.toMap()).toList(),
      'layout': layout.toMap(),
      'overlay': overlay.toMap(),
    };
  }
}

class HeroMediaOverlayData {
  final List<MediaItem> media;
  final Overlay overlay;

  HeroMediaOverlayData({required this.media, required this.overlay});

  factory HeroMediaOverlayData.fromMap(Map<String, dynamic> map) {
    return HeroMediaOverlayData(
      media: List<MediaItem>.from(
        (map['media'] ?? []).map((x) => MediaItem.fromMap(x)),
      ),
      overlay: Overlay.fromMap(map['overlay'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'media': media.map((x) => x.toMap()).toList(),
      'overlay': overlay.toMap(),
    };
  }
}

class MediaItem {
  final String alt;
  final String url;
  final String type;

  MediaItem({required this.alt, required this.url, required this.type});

  factory MediaItem.fromMap(Map<String, dynamic> map) {
    return MediaItem(
      alt: map['alt'] ?? '',
      url: map['url'] ?? '',
      type: map['type'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'alt': alt, 'url': url, 'type': type};
  }
}

class Layout {
  final int gap;
  final String ratio;
  final String stackBreakpoint;

  Layout({
    required this.gap,
    required this.ratio,
    required this.stackBreakpoint,
  });

  factory Layout.fromMap(Map<String, dynamic> map) {
    return Layout(
      gap: map['gap'] ?? 0,
      ratio: map['ratio'] ?? '',
      stackBreakpoint: map['stackBreakpoint'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'gap': gap, 'ratio': ratio, 'stackBreakpoint': stackBreakpoint};
  }
}

class Overlay {
  final String align;
  final double scrimOpacity;
  final String headingPrefix;
  final String headingSuffix;
  final List<String> rotatingWords;
  final String fallbackHeading;

  Overlay({
    required this.align,
    required this.scrimOpacity,
    required this.headingPrefix,
    required this.headingSuffix,
    required this.rotatingWords,
    required this.fallbackHeading,
  });

  factory Overlay.fromMap(Map<String, dynamic> map) {
    return Overlay(
      align: map['align'] ?? '',
      scrimOpacity: (map['scrimOpacity'] ?? 0.0).toDouble(),
      headingPrefix: map['headingPrefix'] ?? '',
      headingSuffix: map['headingSuffix'] ?? '',
      rotatingWords: List<String>.from(map['rotatingWords'] ?? []),
      fallbackHeading: map['fallbackHeading'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'align': align,
      'scrimOpacity': scrimOpacity,
      'headingPrefix': headingPrefix,
      'headingSuffix': headingSuffix,
      'rotatingWords': rotatingWords,
      'fallbackHeading': fallbackHeading,
    };
  }
}

// Content Components
class IntroBlurbCTAsData {
  final String body;
  final List<CTA> ctas;
  final String align;
  final String heading;

  IntroBlurbCTAsData({
    required this.body,
    required this.ctas,
    required this.align,
    required this.heading,
  });

  factory IntroBlurbCTAsData.fromMap(Map<String, dynamic> map) {
    return IntroBlurbCTAsData(
      body: map['body'] ?? '',
      ctas: List<CTA>.from((map['ctas'] ?? []).map((x) => CTA.fromMap(x))),
      align: map['align'] ?? '',
      heading: map['heading'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'body': body,
      'ctas': ctas.map((x) => x.toMap()).toList(),
      'align': align,
      'heading': heading,
    };
  }
}

class CTA {
  final String href;
  final String label;
  final String style;

  CTA({required this.href, required this.label, required this.style});

  factory CTA.fromMap(Map<String, dynamic> map) {
    return CTA(
      href: map['href'] ?? '',
      label: map['label'] ?? '',
      style: map['style'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'href': href, 'label': label, 'style': style};
  }
}

// Discover Grid Component
class DiscoverGridData {
  final String align;
  final String intro;
  final List<DiscoverItem> items;
  final String title;

  DiscoverGridData({
    required this.align,
    required this.intro,
    required this.items,
    required this.title,
  });

  factory DiscoverGridData.fromMap(Map<String, dynamic> map) {
    return DiscoverGridData(
      align: map['align'] ?? '',
      intro: map['intro'] ?? '',
      items: List<DiscoverItem>.from(
        (map['items'] ?? []).map((x) => DiscoverItem.fromMap(x)),
      ),
      title: map['title'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'align': align,
      'intro': intro,
      'items': items.map((x) => x.toMap()).toList(),
      'title': title,
    };
  }
}

class DiscoverItem {
  final CTA cta;
  final String image;
  final String title;
  final String imageAlt;
  final String description;

  DiscoverItem({
    required this.cta,
    required this.image,
    required this.title,
    required this.imageAlt,
    required this.description,
  });

  factory DiscoverItem.fromMap(Map<String, dynamic> map) {
    return DiscoverItem(
      cta: CTA.fromMap(map['cta'] ?? {}),
      image: map['image'] ?? '',
      title: map['title'] ?? '',
      imageAlt: map['imageAlt'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cta': cta.toMap(),
      'image': image,
      'title': title,
      'imageAlt': imageAlt,
      'description': description,
    };
  }
}

// Therapies Accordion Component
class TherapiesAccordionData {
  final String intro;
  final List<TherapyItem> items;
  final String title;
  final TherapyLayout layout;
  final SideImage sideImage;
  final BottomCallout bottomCallout;

  TherapiesAccordionData({
    required this.intro,
    required this.items,
    required this.title,
    required this.layout,
    required this.sideImage,
    required this.bottomCallout,
  });

  factory TherapiesAccordionData.fromMap(Map<String, dynamic> map) {
    return TherapiesAccordionData(
      intro: map['intro'] ?? '',
      items: List<TherapyItem>.from(
        (map['items'] ?? []).map((x) => TherapyItem.fromMap(x)),
      ),
      title: map['title'] ?? '',
      layout: TherapyLayout.fromMap(map['layout'] ?? {}),
      sideImage: SideImage.fromMap(map['sideImage'] ?? {}),
      bottomCallout: BottomCallout.fromMap(map['bottomCallout'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'intro': intro,
      'items': items.map((x) => x.toMap()).toList(),
      'title': title,
      'layout': layout.toMap(),
      'sideImage': sideImage.toMap(),
      'bottomCallout': bottomCallout.toMap(),
    };
  }
}

class TherapyItem {
  final CTA cta;
  final String title;
  final List<String> benefits;
  final String description;

  TherapyItem({
    required this.cta,
    required this.title,
    required this.benefits,
    required this.description,
  });

  factory TherapyItem.fromMap(Map<String, dynamic> map) {
    return TherapyItem(
      cta: CTA.fromMap(map['cta'] ?? {}),
      title: map['title'] ?? '',
      benefits: List<String>.from(map['benefits'] ?? []),
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cta': cta.toMap(),
      'title': title,
      'benefits': benefits,
      'description': description,
    };
  }
}

class TherapyLayout {
  final String mediaPosition;

  TherapyLayout({required this.mediaPosition});

  factory TherapyLayout.fromMap(Map<String, dynamic> map) {
    return TherapyLayout(mediaPosition: map['mediaPosition'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'mediaPosition': mediaPosition};
  }
}

class SideImage {
  final String alt;
  final String url;

  SideImage({required this.alt, required this.url});

  factory SideImage.fromMap(Map<String, dynamic> map) {
    return SideImage(alt: map['alt'] ?? '', url: map['url'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'alt': alt, 'url': url};
  }
}

class BottomCallout {
  final CTA cta;
  final String text;

  BottomCallout({required this.cta, required this.text});

  factory BottomCallout.fromMap(Map<String, dynamic> map) {
    return BottomCallout(
      cta: CTA.fromMap(map['cta'] ?? {}),
      text: map['text'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'cta': cta.toMap(), 'text': text};
  }
}

// Memberships Grid Component
class MembershipsGridData {
  final String intro;
  final List<MembershipItem> items;
  final String title;

  MembershipsGridData({
    required this.intro,
    required this.items,
    required this.title,
  });

  factory MembershipsGridData.fromMap(Map<String, dynamic> map) {
    return MembershipsGridData(
      intro: map['intro'] ?? '',
      items: List<MembershipItem>.from(
        (map['items'] ?? []).map((x) => MembershipItem.fromMap(x)),
      ),
      title: map['title'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'intro': intro,
      'items': items.map((x) => x.toMap()).toList(),
      'title': title,
    };
  }
}

class MembershipItem {
  final CTA cta;
  final String image;
  final String title;
  final String imageAlt;
  final String indexLabel;
  final String description;

  MembershipItem({
    required this.cta,
    required this.image,
    required this.title,
    required this.imageAlt,
    required this.indexLabel,
    required this.description,
  });

  factory MembershipItem.fromMap(Map<String, dynamic> map) {
    return MembershipItem(
      cta: CTA.fromMap(map['cta'] ?? {}),
      image: map['image'] ?? '',
      title: map['title'] ?? '',
      imageAlt: map['imageAlt'] ?? '',
      indexLabel: map['indexLabel'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cta': cta.toMap(),
      'image': image,
      'title': title,
      'imageAlt': imageAlt,
      'indexLabel': indexLabel,
      'description': description,
    };
  }
}

// Social Gallery Component
class SocialGalleryData {
  final String handle;
  final List<SocialImage> images;
  final String source;
  final String heading;
  final String profileUrl;

  SocialGalleryData({
    required this.handle,
    required this.images,
    required this.source,
    required this.heading,
    required this.profileUrl,
  });

  factory SocialGalleryData.fromMap(Map<String, dynamic> map) {
    return SocialGalleryData(
      handle: map['handle'] ?? '',
      images: List<SocialImage>.from(
        (map['images'] ?? []).map((x) => SocialImage.fromMap(x)),
      ),
      source: map['source'] ?? '',
      heading: map['heading'] ?? '',
      profileUrl: map['profileUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'handle': handle,
      'images': images.map((x) => x.toMap()).toList(),
      'source': source,
      'heading': heading,
      'profileUrl': profileUrl,
    };
  }
}

class SocialImage {
  final String alt;
  final String url;

  SocialImage({required this.alt, required this.url});

  factory SocialImage.fromMap(Map<String, dynamic> map) {
    return SocialImage(alt: map['alt'] ?? '', url: map['url'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'alt': alt, 'url': url};
  }
}

// Footer Component
class FooterData {
  final String title;
  final List<FooterGroup> groups;
  final Contact contact;
  final BottomBar bottomBar;
  final Newsletter newsletter;

  FooterData({
    required this.title,
    required this.groups,
    required this.contact,
    required this.bottomBar,
    required this.newsletter,
  });

  factory FooterData.fromMap(Map<String, dynamic> map) {
    return FooterData(
      title: map['title'] ?? '',
      groups: List<FooterGroup>.from(
        (map['groups'] ?? []).map((x) => FooterGroup.fromMap(x)),
      ),
      contact: Contact.fromMap(map['contact'] ?? {}),
      bottomBar: BottomBar.fromMap(map['bottomBar'] ?? {}),
      newsletter: Newsletter.fromMap(map['newsletter'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'groups': groups.map((x) => x.toMap()).toList(),
      'contact': contact.toMap(),
      'bottomBar': bottomBar.toMap(),
      'newsletter': newsletter.toMap(),
    };
  }
}

class FooterGroup {
  final List<FooterLink> links;
  final String heading;

  FooterGroup({required this.links, required this.heading});

  factory FooterGroup.fromMap(Map<String, dynamic> map) {
    return FooterGroup(
      links: List<FooterLink>.from(
        (map['links'] ?? []).map((x) => FooterLink.fromMap(x)),
      ),
      heading: map['heading'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'links': links.map((x) => x.toMap()).toList(), 'heading': heading};
  }
}

class FooterLink {
  final String href;
  final String label;
  final bool? external;

  FooterLink({required this.href, required this.label, this.external});

  factory FooterLink.fromMap(Map<String, dynamic> map) {
    return FooterLink(
      href: map['href'] ?? '',
      label: map['label'] ?? '',
      external: map['external'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'href': href,
      'label': label,
      if (external != null) 'external': external,
    };
  }
}

class Contact {
  final String email;
  final String phone;
  final String heading;
  final String emailHref;
  final String phoneHref;
  final List<String> addressLines;

  Contact({
    required this.email,
    required this.phone,
    required this.heading,
    required this.emailHref,
    required this.phoneHref,
    required this.addressLines,
  });

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      heading: map['heading'] ?? '',
      emailHref: map['emailHref'] ?? '',
      phoneHref: map['phoneHref'] ?? '',
      addressLines: List<String>.from(map['addressLines'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phone': phone,
      'heading': heading,
      'emailHref': emailHref,
      'phoneHref': phoneHref,
      'addressLines': addressLines,
    };
  }
}

class BottomBar {
  final String leftNote;
  final String copyright;
  final List<LegalLink> legalLinks;

  BottomBar({
    required this.leftNote,
    required this.copyright,
    required this.legalLinks,
  });

  factory BottomBar.fromMap(Map<String, dynamic> map) {
    return BottomBar(
      leftNote: map['leftNote'] ?? '',
      copyright: map['copyright'] ?? '',
      legalLinks: List<LegalLink>.from(
        (map['legalLinks'] ?? []).map((x) => LegalLink.fromMap(x)),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'leftNote': leftNote,
      'copyright': copyright,
      'legalLinks': legalLinks.map((x) => x.toMap()).toList(),
    };
  }
}

class LegalLink {
  final String href;
  final String label;

  LegalLink({required this.href, required this.label});

  factory LegalLink.fromMap(Map<String, dynamic> map) {
    return LegalLink(href: map['href'] ?? '', label: map['label'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'href': href, 'label': label};
  }
}

class Newsletter {
  final String action;
  final String heading;
  final String subtext;
  final String submitHref;
  final String placeholder;

  Newsletter({
    required this.action,
    required this.heading,
    required this.subtext,
    required this.submitHref,
    required this.placeholder,
  });

  factory Newsletter.fromMap(Map<String, dynamic> map) {
    return Newsletter(
      action: map['action'] ?? '',
      heading: map['heading'] ?? '',
      subtext: map['subtext'] ?? '',
      submitHref: map['submitHref'] ?? '',
      placeholder: map['placeholder'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'heading': heading,
      'subtext': subtext,
      'submitHref': submitHref,
      'placeholder': placeholder,
    };
  }
}

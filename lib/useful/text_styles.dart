import 'package:flutter/material.dart';

/// A centralized registry of [TextStyle] constants used throughout the OWA
/// application.
///
/// Every style in this class is derived directly from a Figma design token and
/// follows a strict, repeatable mapping so that any designer handoff can be
/// translated to Flutter without ambiguity.
///
/// ---
///
/// ## Figma → Flutter conversion rules
///
/// | Figma property     | Figma format       | Flutter property  | Conversion formula                              |
/// |--------------------|--------------------|-------------------|-------------------------------------------------|
/// | `font-family`      | Font name string   | `fontFamily`      | Use the matching private `_fontName` constant   |
/// | `font-weight`      | Numeric (300–900)  | `fontWeight`      | `FontWeight.wN` — round to nearest 100; 350 → `w400` |
/// | `font-style`       | Book/Regular/Light | `fontStyle`       | All upright styles → `FontStyle.normal`         |
/// | `font-size`        | `Npx`              | `fontSize`        | Drop `px`, use as `double`                      |
/// | `line-height` (px) | `Npx`              | `height`          | `lineHeightPx / fontSizePx`                     |
/// | `line-height` (%)  | `N%`               | `height`          | `N / 100`                                       |
/// | `letter-spacing` (%) | `N%`            | `letterSpacing`   | `fontSize * N / 100`                            |
/// | `letter-spacing` (px) | `Npx`          | `letterSpacing`   | Use value directly as `double`                  |
/// | `color` (hex)      | `#RRGGBB`          | `color`           | `Color.fromRGBO(R, G, B, 1)`                    |
/// | `text-transform`   | `uppercase`        | —                 | No Flutter equivalent; apply at the widget level with `toUpperCase()` |
/// | `vertical-align`   | `middle`           | —                 | No Flutter equivalent; handle with parent widget alignment |
/// | `leading-trim`     | `NONE`             | —                 | No Flutter equivalent; ignore                   |
///
/// ---
///
/// ## Adding a new style from Figma
///
/// 1. **Copy the Figma token block** from the inspector panel and paste it as
///    a comment block next to the new style so future developers can trace it
///    back to the source.
///
/// 2. **Add the font family** to the private constants at the top of the class
///    if it is not already present, and register the font in `pubspec.yaml`.
///
/// 3. **Declare the static field** following the pattern below:
///
/// ```dart
/// // Figma:
/// // font-family: TWK Everett;
/// // font-weight: 400;
/// // font-style: Regular;
/// // font-size: 16px;
/// // line-height: 24px;
/// // letter-spacing: 0%;
/// // color: #2F2F2F;
/// static TextStyle myNewStyle = const TextStyle(
///   fontFamily: _twkEverett,           // matched private constant
///   fontWeight: FontWeight.w400,        // Figma 400 → w400
///   fontStyle: FontStyle.normal,        // Regular → normal
///   fontSize: 16.0,                     // 16px → 16.0
///   height: 24 / 16,                    // 24px ÷ 16px = 1.5
///   letterSpacing: 0.0,                 // 0% of 16px = 0.0
///   color: Color.fromRGBO(47, 47, 47, 1),
///   overflow: TextOverflow.fade,        // always add this line
/// );
/// ```
///
/// 4. **Name the field** using the pattern `<screen><Section><Role>`, for
///    example `aboutPageImpactItemTitle`, so names remain self-documenting and
///    easy to locate by screen.
class OWATextStyles {
  OWATextStyles._();

  // Font Families
  static const String _arbeit = 'Arbeit';
  static const String _timesNow = 'Times Now';
  static const String _uncutSans = 'Uncut Sans';
  static const String _twkEverett = 'TWK Everett';
  static const String _instrumentSans = 'Instrument Sans';
  static const String _basierCircleMono = 'Basier Circle Mono';

  static TextStyle heroMainText = const TextStyle(
    fontFamily: _timesNow,
    fontSize: 22,
    fontWeight: FontWeight.w400,
    height: 1.34,
    letterSpacing: 0,
    color: Color.fromRGBO(247, 240, 233, 1),
    overflow: TextOverflow.fade,
    // font-family: Times Now;
    // font-weight: 400;
    // font-style: SemiLight;
    // font-size: 22px;
    // leading-trim: NONE;
    // line-height: 134%;
    // letter-spacing: 0%;
    // text-align: center;
    // rgba(247, 240, 233, 1)
  );

  static TextStyle heroMainButtonText = const TextStyle(
    fontFamily: 'Basier Circle Mono',
    fontWeight: FontWeight.w400,
    fontSize: 11,
    height: 1.5,
    letterSpacing: 0.0,
    color: Color.fromRGBO(249, 239, 228, 1),
    // font-family: Basier Circle Mono;
    // font-weight: 400;
    // font-style: Regular;
    // font-size: 11px;
    // leading-trim: NONE;
    // line-height: 150%;
    // letter-spacing: 0%;
    // text-align: center;
  );

  static TextStyle discoverCardTitle = const TextStyle(
    fontFamily: _basierCircleMono,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    fontSize: 14.0,
    height: 38.14 / 14.0, // line-height as ratio
    letterSpacing: 2.1, // 15% of 14px = 14 * 0.15 = 2.1
    color: Color.fromRGBO(247, 240, 233, 1),
    overflow: TextOverflow.fade,
  );

  static TextStyle discoverCardFooterText = const TextStyle(
    fontFamily: _basierCircleMono,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    fontSize: 12.0,
    height: 38.14 / 14.0, // line-height as ratio
    letterSpacing: 2.1, // 15% of 14px = 14 * 0.15 = 2.1
    color: Color.fromRGBO(247, 240, 233, 1),
    overflow: TextOverflow.fade,
  );

  static TextStyle discoverCardSubtitle = const TextStyle(
    fontFamily: _instrumentSans,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    fontSize: 13.0,
    height: 19.0 / 13.0, // line-height as ratio (19px / 13px ≈ 1.46)
    letterSpacing: 0.0, // 0% = 0
    color: Color.fromRGBO(228, 225, 215, 1),
    overflow: TextOverflow.fade,
  );

  static TextStyle sectionSubtitle = const TextStyle(
    fontFamily: _timesNow,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    fontSize: 19.0,
    height: 26.0 / 19.0,
    letterSpacing: 0.0, // 0% = 0
    color: Color.fromRGBO(47, 47, 47, 1),
    overflow: TextOverflow.fade,
  );

  static TextStyle sectionTitle = const TextStyle(
    fontFamily: _instrumentSans,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal,
    fontSize: 20.0,
    height: 1.51,
    letterSpacing: 0.0, // 0% = 0
    color: Color.fromRGBO(0, 0, 0, 1),
    overflow: TextOverflow.fade,
  );

  static TextStyle sectionTitleIndex = const TextStyle(
    fontFamily: _basierCircleMono,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal,
    fontSize: 10.0,
    height: 1.5,
    letterSpacing: 0.0, // 0% = 0
    color: Color.fromRGBO(0, 0, 0, 1),
    overflow: TextOverflow.fade,
  );

  static TextStyle drawerFooterAddressText = const TextStyle(
    fontFamily: _twkEverett,
    fontWeight: FontWeight.w300,
    fontSize: 14,
    height: 23 / 14,
    letterSpacing: 0,
    color: Colors.white,

    /// extras
    overflow: TextOverflow.fade,

    // font-family: Matter;
    // font-weight: 300;
    // font-style: Light;
    // font-size: 14px;
    // leading-trim: NONE;
    // line-height: 23px;
    // letter-spacing: 0%;
  );

  static TextStyle drawerFooterCallToActionText = const TextStyle(
    fontFamily: _twkEverett,
    fontWeight: FontWeight.w400,
    fontSize: 13.9,
    height: 23 / 13.9,
    letterSpacing: 0,
    color: Colors.white,

    /// extras
    overflow: TextOverflow.fade,

    // font-family: Matter;
    // font-weight: 300;
    // font-style: Light;
    // font-size: 14px;
    // leading-trim: NONE;
    // line-height: 23px;
    // letter-spacing: 0%;
  );

  static TextStyle footerCallToActionText = const TextStyle(
    // font-family: Matter;
    fontFamily: _uncutSans,
    fontWeight: FontWeight.w300,
    fontStyle: FontStyle.normal, // light
    fontSize: 13.0,
    height: 22.4 / 13.0,
    letterSpacing: 0.0,
    color: Color.fromRGBO(246, 243, 238, 1),

    /// extras
    overflow: TextOverflow.fade,
  );

  static TextStyle footerCallToActionTextHover = const TextStyle(
    // font-family: Matter;
    fontFamily: _uncutSans,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal, // light
    fontSize: 12.9,
    height: 22.4 / 12.9,
    letterSpacing: 0.0,
    color: Color.fromRGBO(246, 243, 238, 1),

    /// extras
    overflow: TextOverflow.fade,
  );

  static TextStyle footerBottomItem = const TextStyle(
    // font-family: Matter;
    fontFamily: _instrumentSans,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal, // light
    fontSize: 10.0,
    height: 1.4,
    letterSpacing: 0.0,
    color: Color.fromRGBO(159, 145, 129, 1),

    /// extras
    overflow: TextOverflow.fade,
    // font-family: Instrument Sans;
    // font-weight: 500;
    // font-style: Medium;
    // font-size: 10px;
    // leading-trim: NONE;
    // line-height: 140%;
    // letter-spacing: 0%;
  );

  static TextStyle footerTitleSection = const TextStyle(
    // font-family: Matter;
    fontFamily: _basierCircleMono,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal, // light
    fontSize: 15.0,
    height: 1.73,
    letterSpacing: 0.0,
    color: Color.fromRGBO(159, 145, 129, 1),

    /// extras
    overflow: TextOverflow.fade,

    // font-family: Basier Circle Mono;
    // font-weight: 400;
    // font-style: Regular;
    // font-size: 15px;
    // leading-trim: NONE;
    // line-height: 173%;
    // letter-spacing: 0%;
  );
}

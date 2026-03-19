import 'package:flutter/material.dart';
import 'package:owa_flutter/cart/cart_scope.dart';
import 'package:owa_flutter/cart/cart_store.dart';
import 'package:owa_flutter/crud/privacy_notice_screen.dart';
import 'package:owa_flutter/screens/cart/shopping_cart_page.dart';
import 'package:owa_flutter/screens/checkout/complete_sale_page.dart';
import 'package:owa_flutter/screens/checkout/payment_redirect_page.dart';
import 'package:owa_flutter/screens/landing_page.dart';
import 'package:owa_flutter/screens/cart/cart_dummy_data.dart';
import 'package:owa_flutter/screens/owa_faq_page.dart';
import 'package:owa_flutter/screens/profile/my_bookings_page.dart';
import 'package:owa_flutter/screens/profile/settings_page.dart';
import 'package:owa_flutter/useful/fade_page_transitions_builder.dart';
import 'package:owa_flutter/useful/is_desktop_from_context.dart';
import 'package:owa_flutter/useful/size_config.dart';

class OWAApp extends StatefulWidget {
  const OWAApp({super.key});

  @override
  State<OWAApp> createState() => _OWAAppState();
}

class _OWAAppState extends State<OWAApp> {
  late final CartStore _cartStore;

  @override
  void initState() {
    super.initState();
    _cartStore = CartStore(
      initialItems: [
        CartItem(
          id: 'membership-basic',
          type: CartItemType.membership,
          name: kCartDummyItems[0].name,
          price: kCartDummyItems[0].price,
          qty: kCartDummyItems[0].qty,
        ),
        CartItem(
          id: 'therapy-session',
          type: CartItemType.service,
          name: kCartDummyItems[1].name,
          price: kCartDummyItems[1].price,
          qty: kCartDummyItems[1].qty,
        ),
        CartItem(
          id: 'breathwork-class',
          type: CartItemType.event,
          name: kCartDummyItems[2].name,
          price: kCartDummyItems[2].price,
          qty: kCartDummyItems[2].qty,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cartStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Set your Figma frame size
    SizeConfig.init(
      context,
      figmaWidth: isDesktopFromContext(context) ? 1440 : 430,
      figmaHeight: isDesktopFromContext(context) ? 885 : 932,
    );
    // print("==============================");
    // print("width: ${MediaQuery.of(context).size.width}");
    // print("height: ${MediaQuery.of(context).size.height}");

    // print("SizeConfig.screenWidth: ${SizeConfig.screenWidth}");
    // print("SizeConfig.screenHeight: ${SizeConfig.screenHeight}");

    // print("SizeConfig.scaleWidth: ${SizeConfig.scaleWidth}");
    // print("SizeConfig.scaleHeight: ${SizeConfig.scaleHeight}");
    // print("==============================");

    return CartScope(
      store: _cartStore,
      child: MaterialApp(
        title: 'OWA',
        theme: ThemeData(primarySwatch: Colors.brown, fontFamily: 'Inter'),
        initialRoute: '/',

        /// Note: home and routes removed in order to use FadeRoute correclty
        onGenerateRoute: (settings) {
          /// Aldo's logic
          if (settings.name != null && settings.name!.startsWith('/redirect')) {
            return MaterialPageRoute(
              builder:
                  (_) => PaymentRedirectPage(
                    routeName: settings.name,
                    routeArguments: settings.arguments,
                  ),
              settings: settings,
            );
          }

          /// Smooth page transition
          Widget page;
          switch (settings.name) {
            case '/':
              String? initialSection;
              final args = settings.arguments;
              if (args is String && args.isNotEmpty) {
                initialSection = args;
              } else if (args is Map) {
                final dynamic section = args['section'];
                if (section is String && section.isNotEmpty) {
                  initialSection = section;
                }
              }
              page = OWALandingPage(initialSection: initialSection);
              break;
            case '/privacy-notice':
              page = const OWAPrivacyNoticePage();
              break;
            case '/cart':
              page = const ShoppingCartPage();
              break;
            case '/checkout':
              page = const CompleteSalePage();
              break;
            case '/redirect':
              page = const PaymentRedirectPage();
              break;
            case '/profile/bookings':
              page = const MyBookingsPage();
              break;
            case '/profile/settings':
              page = const SettingsPage();
              break;
            case '/faq':
              page = const OWAFAQPageParallaxV3();
              break;
            default:
              // 404 page or redirect to home
              page = const OWALandingPage();
          }
          return FadeRoute(builder: (context) => page, settings: settings);
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

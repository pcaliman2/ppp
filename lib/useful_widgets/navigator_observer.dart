import 'package:flutter/material.dart';

class ANRONavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    print('📍 Pushed: ${route.settings.name}');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    print('📍 Popped: ${route.settings.name}');
  }
}

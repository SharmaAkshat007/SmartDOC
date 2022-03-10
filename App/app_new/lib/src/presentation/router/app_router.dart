import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../screens/home_screen/home_screen.dart';
import '../screens/splash_screen/splash_screen.dart';

class AppRouter {
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Strings.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      case Strings.home:
        return MaterialPageRoute(
          builder: (_) => const Home(),
        );
      default:
        null;
    }
    return null;
  }
}

import 'package:flutter/material.dart';

import '../features/splash/presentation/splash_screen.dart';
import '../features/game/presentation/game_page.dart';

/// Point unique où déclarer les routes de l'app.
/// Ajoute un `case` ici à chaque nouvel écran créé dans `features/`.
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case '/game':
        return MaterialPageRoute(builder: (_) => const GamePage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route inconnue : ${settings.name}')),
          ),
        );
    }
  }
}

import 'package:flutter/material.dart';

import 'router.dart';

/// Widget racine de l'application PictoWord.
/// C'est ici que sont définis le thème global et le point de départ du routage.
class PictoWordApp extends StatelessWidget {
  const PictoWordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PictoWord',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }

  /// Thème sombre violet, cohérent avec la maquette de design fournie
  /// (fond très sombre, accents violets, textes clairs).
  ThemeData _buildTheme() {
    const violet = Color(0xFF7B2FF7);
    const violetSoft = Color(0xFF9B59F7);
    const background = Color(0xFF08080E);
    const surface = Color(0xFF12121D);
    const textColor = Color(0xFFEEEEF5);

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: violet,
        brightness: Brightness.dark,
      ).copyWith(secondary: violetSoft, surface: surface),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Écran principal du jeu (1 image, 4 mots).
/// Pour l'instant c'est un placeholder : à remplacer par la vraie logique
/// (features/game/engine/answer_generator.dart, .../data/game_repository.dart,
/// .../models/game_session.dart, .../presentation/answer_button.dart, image_card.dart).
class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Écran de jeu à venir')));
  }
}

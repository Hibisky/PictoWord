
import 'package:flutter/material.dart';

/// Résultat à afficher par-dessus l'image une fois que le joueur a répondu.
enum AnswerFeedback { none, correct, wrong }

/// Carte image en haut de l'écran de jeu.
///
/// Affiche l'image de la question, un léger dégradé sombre en bas
/// (purement esthétique), et un overlay ✓ / ✗ quand [feedback]
/// n'est pas `AnswerFeedback.none`.
class ImageCard extends StatelessWidget {
  const ImageCard({
    super.key,
    required this.imagePath,
    this.feedback = AnswerFeedback.none,
  });

  /// Chemin de l'asset, ex: 'assets/images/animaux/lion.webp'.
  final String imagePath;

  final AnswerFeedback feedback;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // Coins arrondis, comme dans la maquette (rounded-3xl).
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        // fit: expand force chaque enfant du Stack à remplir tout l'espace disponible.
        fit: StackFit.expand,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),

          // Dégradé transparent -> noir semi-transparent, du haut vers le bas.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x80000000)],
                stops: [0.55, 1.0],
              ),
            ),
          ),

          // L'overlay ne s'affiche que si une réponse vient d'être donnée.
          if (feedback != AnswerFeedback.none) _FeedbackOverlay(feedback: feedback),
        ],
      ),
    );
  }
}

/// Rond coloré (vert = bonne réponse, rouge = mauvaise) avec une icône
/// ✓ ou ✗ au centre, affiché par-dessus l'image après une réponse.
class _FeedbackOverlay extends StatelessWidget {
  const _FeedbackOverlay({required this.feedback});

  final AnswerFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final bool isCorrect = feedback == AnswerFeedback.correct;
    final Color color = isCorrect ? const Color(0xFF16C464) : const Color(0xFFE5383B);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: color.withValues(alpha: 0.15),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 30),
            ],
          ),
          child: Icon(
            isCorrect ? Icons.check : Icons.close,
            color: Colors.white,
            size: 38,
          ),
        ),
      ),
    );
  }
}
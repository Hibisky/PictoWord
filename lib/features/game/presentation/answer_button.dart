
import 'package:flutter/material.dart';

/// État visuel d'un bouton, décidé par la page de jeu une fois
/// qu'une réponse a été sélectionnée.
enum AnswerState {
  idle, // avant toute sélection : cliquable, couleur neutre
  correct, // c'est la bonne réponse : vert
  wrong, // le joueur a choisi celle-ci et c'est faux : rouge
  dim, // ni sélectionnée ni correcte : atténuée pour ne pas distraire
}

/// Un bouton de la grille de réponses (2x2).
class AnswerButton extends StatelessWidget {
  const AnswerButton({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final AnswerState state;
  final VoidCallback onTap;

  // Couleurs reprises de la maquette (thème sombre / violet).
  static const _idleBackground = Color(0xFF1A1A2A);
  static const _idleBorder = Color(0x387B2FF7);
  static const _idleText = Color(0xFFEEEEF5);

  @override
  Widget build(BuildContext context) {
    final bool isTappable = state == AnswerState.idle;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _backgroundColor(),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor(), width: 1.5),
        boxShadow: _glow(),
      ),
      // Material + InkWell : nécessaire pour avoir l'effet "ripple" au
      // toucher tout en gardant nos propres couleurs de fond/bordure.
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          // onTap à `null` désactive complètement le bouton (plus de ripple,
          // plus de callback) dès qu'une réponse a déjà été donnée.
          onTap: isTappable ? onTap : null,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state == AnswerState.correct)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.check, color: Color(0xFF4ADE80), size: 18),
                  ),
                if (state == AnswerState.wrong)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.close, color: Color(0xFFF87171), size: 18),
                  ),
                Text(
                  label,
                  style: TextStyle(
                    color: _textColor(),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _backgroundColor() {
    switch (state) {
      case AnswerState.correct:
        return const Color(0x2E16C464);
      case AnswerState.wrong:
        return const Color(0x2EE5383B);
      case AnswerState.dim:
        return const Color(0x801A1A2A);
      case AnswerState.idle:
        return _idleBackground;
    }
  }

  Color _borderColor() {
    switch (state) {
      case AnswerState.correct:
        return const Color(0xD916C464);
      case AnswerState.wrong:
        return const Color(0xD9E5383B);
      case AnswerState.dim:
        return const Color(0x1A7B2FF7);
      case AnswerState.idle:
        return _idleBorder;
    }
  }

  Color _textColor() {
    switch (state) {
      case AnswerState.correct:
        return const Color(0xFF4ADE80);
      case AnswerState.wrong:
        return const Color(0xFFF87171);
      case AnswerState.dim:
        return const Color(0xFF6C6C8A);
      case AnswerState.idle:
        return _idleText;
    }
  }

  List<BoxShadow> _glow() {
    switch (state) {
      case AnswerState.correct:
        return [BoxShadow(color: const Color(0xFF16C464).withValues(alpha: 0.35), blurRadius: 18)];
      case AnswerState.wrong:
        return [BoxShadow(color: const Color(0xFFE5383B).withValues(alpha: 0.35), blurRadius: 18)];
      default:
        return const [];
    }
  }
}
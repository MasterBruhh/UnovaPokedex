import 'package:flutter/material.dart';

import '../../theme/trivia_colors.dart';

/// Widget que muestra la puntuación actual en el juego de trivia.
/// 
/// Muestra la puntuación con un diseño temático de Pokéball.
class ScoreDisplay extends StatelessWidget {
  /// La puntuación actual a mostrar
  final int score;
  
  /// Multiplicador de tamaño opcional para el display
  final double sizeMultiplier;

  const ScoreDisplay({
    super.key,
    required this.score,
    this.sizeMultiplier = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20 * sizeMultiplier,
        vertical: 10 * sizeMultiplier,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TriviaColors.accent, TriviaColors.accentLight],
        ),
        borderRadius: BorderRadius.circular(30 * sizeMultiplier),
        boxShadow: [
          BoxShadow(
            color: TriviaColors.accent.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.catching_pokemon,
            color: TriviaColors.primary,
            size: 28 * sizeMultiplier,
          ),
          SizedBox(width: 8 * sizeMultiplier),
          Text(
            'Score: $score',
            style: TextStyle(
              fontSize: 20 * sizeMultiplier,
              fontWeight: FontWeight.bold,
              color: TriviaColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Display de puntuación grande para pantalla de game over.
class ScoreDisplayLarge extends StatelessWidget {
  /// La puntuación final a mostrar
  final int score;
  
  /// Texto de etiqueta opcional
  final String label;

  const ScoreDisplayLarge({
    super.key,
    required this.score,
    this.label = 'Final Score',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: TriviaColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          decoration: BoxDecoration(
            gradient: TriviaColors.pokemonGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: TriviaColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.catching_pokemon,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(width: 12),
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

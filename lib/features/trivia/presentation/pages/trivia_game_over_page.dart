import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/yellow_grid_background.dart';
import '../../theme/trivia_colors.dart';
import '../providers/trivia_provider.dart';
import '../widgets/score_display.dart';

/// Pantalla de game over que se muestra cuando el jugador responde incorrectamente.
/// 
/// Muestra la puntuación final y opciones para jugar de nuevo o volver al menú.
class TriviaGameOverPage extends ConsumerWidget {
  /// La puntuación final lograda por el jugador
  final int score;

  const TriviaGameOverPage({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B7500),
      body: Stack(
        children: [
          const Positioned.fill(child: YellowGridBackground()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Ícono de Game Over
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sentiment_dissatisfied,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Texto de Game Over
                  const Text(
                    'GAME OVER',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Display de puntuación
                  ScoreDisplayLarge(
                    score: score,
                    label: 'Tu puntuación',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Mensaje de ánimo
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getEncouragementMessage(score),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Botón de jugar de nuevo
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _playAgain(context, ref),
                      icon: const Icon(Icons.refresh, size: 28),
                      label: const Text(
                        'JUGAR DE NUEVO',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TriviaColors.accent,
                        foregroundColor: TriviaColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Botón de menú principal
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _goToMainMenu(context, ref),
                      icon: const Icon(Icons.home, size: 24),
                      label: const Text(
                        'MENÚ PRINCIPAL',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getEncouragementMessage(int score) {
    if (score == 0) {
      return "¡No te rindas! Todo Maestro Pokémon empezó en algún lugar.";
    } else if (score < 5) {
      return "¡Buen comienzo! ¡Sigue entrenando para convertirte en Maestro Pokémon!";
    } else if (score < 10) {
      return "¡Buen trabajo! ¡Estás en camino a la grandeza!";
    } else if (score < 20) {
      return "¡Impresionante! ¡Realmente conoces a tus Pokémon!";
    } else {
      return "¡Increíble! ¡Eres un verdadero Maestro Pokémon!";
    }
  }

  void _playAgain(BuildContext context, WidgetRef ref) {
    ref.read(triviaProvider.notifier).resetGame();
    context.pushReplacementNamed('trivia_game');
  }

  void _goToMainMenu(BuildContext context, WidgetRef ref) {
    ref.read(triviaProvider.notifier).resetGame();
    context.goNamed('menu');
  }
}

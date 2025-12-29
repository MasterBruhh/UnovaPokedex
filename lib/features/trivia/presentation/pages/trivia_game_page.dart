import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/yellow_grid_background.dart';
import '../../theme/trivia_colors.dart';
import '../../domain/enums/question_type.dart';
import '../providers/trivia_provider.dart';
import '../widgets/widgets.dart';

/// Pantalla principal del juego de trivia.
/// 
/// Muestra la pregunta actual y las opciones de respuesta.
/// Maneja el flujo del juego basado en el estado del provider.
class TriviaGamePage extends ConsumerStatefulWidget {
  const TriviaGamePage({super.key});

  @override
  ConsumerState<TriviaGamePage> createState() => _TriviaGamePageState();
}

class _TriviaGamePageState extends ConsumerState<TriviaGamePage> {
  @override
  void initState() {
    super.initState();
    // Iniciar el juego cuando la pantalla carga
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(triviaProvider.notifier).startGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(triviaProvider);
    
    // Escuchar cambios de estado para navegación
    ref.listen<TriviaGameState>(triviaProvider, (previous, next) {
      if (next.state == TriviaState.gameOver) {
        // Navegar a game over screen
        context.pushReplacementNamed(
          'trivia_game_over',
          pathParameters: {'score': next.score.toString()},
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF8B7500),
      body: Stack(
        children: [
          const Positioned.fill(child: YellowGridBackground()),
          SafeArea(
            child: _buildContent(context, gameState),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, TriviaGameState gameState) {
    switch (gameState.state) {
      case TriviaState.initial:
      case TriviaState.loading:
        return const PokemonLoadingWidget(
          message: 'Cargando pregunta...',
        );

      case TriviaState.error:
        return TriviaErrorWidget(
          message: gameState.errorMessage,
          onRetry: () => ref.read(triviaProvider.notifier).retryLoad(),
        );

      case TriviaState.gameOver:
        // Este caso se maneja en el listener
        return const SizedBox.shrink();

      case TriviaState.playing:
      case TriviaState.answered:
        return _buildGameContent(context, gameState);
    }
  }

  Widget _buildGameContent(BuildContext context, TriviaGameState gameState) {
    final question = gameState.currentQuestion;
    if (question == null) {
      return const TriviaLoadingWidget(message: 'Cargando...');
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header con puntuación
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _showExitDialog(context),
                icon: const Icon(Icons.close, color: Colors.white),
                iconSize: 28,
              ),
              ScoreDisplay(score: gameState.score),
              const SizedBox(width: 48), // Balance del layout
            ],
          ),
          
          const SizedBox(height: 16),

          // Contenido de la pregunta
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Tarjeta de pregunta
                  QuestionCard(question: question),
                  
                  const SizedBox(height: 24),

                  // Imagen de silueta (solo para preguntas de silueta)
                  if (question.type == QuestionType.silhouette) ...[
                    PokemonSilhouette(
                      imageUrl: question.spriteUrl,
                      size: 200,
                      isRevealed: gameState.isRevealed,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Opciones de respuesta
                  ...question.options.map((option) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OptionButton(
                        pokemon: option,
                        state: gameState.getOptionState(option),
                        enabled: gameState.state == TriviaState.playing,
                        onPressed: () => ref.read(triviaProvider.notifier).submitAnswer(option),
                      ),
                    );
                  }),
                  
                  // Mensaje de feedback cuando se responde
                  if (gameState.state == TriviaState.answered) ...[
                    const SizedBox(height: 16),
                    _buildFeedbackMessage(gameState),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackMessage(TriviaGameState gameState) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: gameState.wasAnswerCorrect
            ? TriviaColors.correctAnswer
            : TriviaColors.wrongAnswer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            gameState.wasAnswerCorrect ? Icons.check_circle : Icons.cancel,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            gameState.wasAnswerCorrect ? '¡Correcto!' : '¡Incorrecto!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Salir del juego?'),
        content: const Text('¿Estás seguro de que quieres salir? Tu progreso se perderá.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(triviaProvider.notifier).resetGame();
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TriviaColors.error,
            ),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}

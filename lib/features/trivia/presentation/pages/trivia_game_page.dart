import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../theme/trivia_colors.dart';
import '../../domain/enums/question_type.dart';
import '../providers/trivia_provider.dart';
import '../widgets/widgets.dart';

class TriviaGamePage extends ConsumerStatefulWidget {
  const TriviaGamePage({super.key});

  @override
  ConsumerState<TriviaGamePage> createState() => _TriviaGamePageState();
}

class _TriviaGamePageState extends ConsumerState<TriviaGamePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(triviaProvider.notifier).startGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(triviaProvider);

    final l10n = AppLocalizations.of(context)!;

    ref.listen<TriviaGameState>(triviaProvider, (previous, next) {
      if (next.state == TriviaState.gameOver) {
        context.pushReplacementNamed(
          'trivia_game_over',
          pathParameters: {'score': next.score.toString()},
        );
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: TriviaColors.backgroundGradient,
        ),
        child: SafeArea(
          // PASAR L10N A LOS WIDGETS HIJOS
          child: _buildContent(context, gameState, l10n),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TriviaGameState gameState, AppLocalizations l10n) {
    switch (gameState.state) {
      case TriviaState.initial:
      case TriviaState.loading:
        return PokemonLoadingWidget(
          message: l10n.loadingQuestion, // Traducido
        );

      case TriviaState.error:
        return TriviaErrorWidget(
          message: gameState.errorMessage,
          onRetry: () => ref.read(triviaProvider.notifier).retryLoad(),
        );

      case TriviaState.gameOver:
        return const SizedBox.shrink();

      case TriviaState.playing:
      case TriviaState.answered:
        return _buildGameContent(context, gameState, l10n);
    }
  }

  Widget _buildGameContent(BuildContext context, TriviaGameState gameState, AppLocalizations l10n) {
    final question = gameState.currentQuestion;
    if (question == null) {
      return TriviaLoadingWidget(message: l10n.loadingQuestion);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _showExitDialog(context, l10n),
                icon: const Icon(Icons.close, color: Colors.white),
                iconSize: 28,
              ),
              ScoreDisplay(score: gameState.score),
              const SizedBox(width: 48),
            ],
          ),

          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  QuestionCard(question: question),

                  const SizedBox(height: 24),

                  if (question.type == QuestionType.silhouette) ...[
                    PokemonSilhouette(
                      imageUrl: question.spriteUrl,
                      size: 200,
                      isRevealed: gameState.isRevealed,
                    ),
                    const SizedBox(height: 24),
                  ],

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

                  if (gameState.state == TriviaState.answered) ...[
                    const SizedBox(height: 16),
                    _buildFeedbackMessage(gameState, l10n),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackMessage(TriviaGameState gameState, AppLocalizations l10n) {
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
            // Traducido
            gameState.wasAnswerCorrect ? l10n.correctAnswer : l10n.wrongAnswer,
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

  void _showExitDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.exitGameTitle), // Traducido
        content: Text(l10n.exitGameContent), // Traducido
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel), // Traducido
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
            child: Text(l10n.exit), // Traducido
          ),
        ],
      ),
    );
  }
}
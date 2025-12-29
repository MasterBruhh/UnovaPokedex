import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// 1. IMPORTAR L10N
import 'package:pokedex/l10n/app_localizations.dart';

import '../../theme/trivia_colors.dart';
import '../providers/trivia_provider.dart';
import '../widgets/score_display.dart';

class TriviaGameOverPage extends ConsumerWidget {
  final int score;

  const TriviaGameOverPage({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: TriviaColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

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

                Text(
                  l10n.gameOver, // TRADUCIDO
                  style: const TextStyle(
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

                ScoreDisplayLarge(
                  score: score,
                  label: l10n.yourScore, // TRADUCIDO
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getEncouragementMessage(score, l10n), // PASAR l10n
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _playAgain(context, ref),
                    icon: const Icon(Icons.refresh, size: 28),
                    label: Text(
                      l10n.playAgain, // TRADUCIDO
                      style: const TextStyle(
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

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _goToMainMenu(context, ref),
                    icon: const Icon(Icons.home, size: 24),
                    label: Text(
                      l10n.mainMenu, // TRADUCIDO
                      style: const TextStyle(
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
      ),
    );
  }

  // TRADUCCIÓN DE MENSAJES DE ÁNIMO
  String _getEncouragementMessage(int score, AppLocalizations l10n) {
    if (score == 0) {
      return l10n.scoreMsg0;
    } else if (score < 5) {
      return l10n.scoreMsgLow;
    } else if (score < 10) {
      return l10n.scoreMsgMid;
    } else if (score < 20) {
      return l10n.scoreMsgHigh;
    } else {
      return l10n.scoreMsgMax;
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
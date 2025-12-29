import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../../../core/widgets/yellow_grid_background.dart';
import '../../theme/trivia_colors.dart';
import '../providers/trivia_provider.dart';
import '../widgets/score_display.dart';
import '../widgets/achievement_badge.dart';

class TriviaGameOverPage extends ConsumerStatefulWidget {
  final int score;

  const TriviaGameOverPage({
    super.key,
    required this.score,
  });

  @override
  ConsumerState<TriviaGameOverPage> createState() => _TriviaGameOverPageState();
}

class _TriviaGameOverPageState extends ConsumerState<TriviaGameOverPage> {
  @override
  void initState() {
    super.initState();
    // Mostrar logros desbloqueados después de construir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showNewAchievements();
    });
  }

  void _showNewAchievements() {
    final gameState = ref.read(triviaProvider);
    if (gameState.newlyUnlockedAchievements.isNotEmpty) {
      for (final achievement in gameState.newlyUnlockedAchievements) {
        showDialog(
          context: context,
          builder: (ctx) => NewAchievementDialog(achievement: achievement),
        );
      }
      ref.read(triviaProvider.notifier).clearNewAchievements();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                  score: widget.score,
                  label: l10n.yourScore,
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getEncouragementMessage(widget.score, l10n),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const Spacer(),

                // Botón Jugar de nuevo
                Semantics(
                  label: l10n.playAgain,
                  button: true,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _playAgain(context),
                      icon: const Icon(Icons.refresh, size: 28),
                      label: Text(
                        l10n.playAgain,
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
                ),
                const SizedBox(height: 12),

                // Botón Ver Ranking
                Semantics(
                  label: l10n.viewRanking,
                  button: true,
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.pushNamed('trivia_ranking'),
                      icon: const Icon(Icons.leaderboard, size: 24),
                      label: Text(
                        l10n.viewRanking,
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
                ),
                const SizedBox(height: 12),

                // Botón Menú Principal
                Semantics(
                  label: l10n.mainMenu,
                  button: true,
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => _goToMainMenu(context),
                      icon: const Icon(Icons.home, size: 24),
                      label: Text(
                        l10n.mainMenu,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          )],
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

  void _playAgain(BuildContext context) {
    ref.read(triviaProvider.notifier).resetGame();
    context.pushReplacementNamed('trivia_game');
  }

  void _goToMainMenu(BuildContext context) {
    ref.read(triviaProvider.notifier).resetGame();
    context.goNamed('menu');
  }
}
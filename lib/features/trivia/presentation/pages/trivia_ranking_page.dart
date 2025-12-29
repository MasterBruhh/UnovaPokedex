import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../../../core/widgets/yellow_grid_background.dart';
import '../../theme/trivia_colors.dart';
import '../providers/trivia_provider.dart';
import '../widgets/ranking_list.dart';
import '../widgets/achievement_badge.dart';

/// Pantalla de ranking y logros
class TriviaRankingPage extends ConsumerWidget {
  const TriviaRankingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF8B7500),
        body: Stack(
          children: [
            const Positioned.fill(child: YellowGridBackground()),
            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Semantics(
                          label: l10n.backButtonLabel,
                          button: true,
                          child: IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            iconSize: 28,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.rankingAndAchievements,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Best Score Card
                  _buildBestScoreCard(context, ref, l10n),
                  const SizedBox(height: 16),
                  // TabBar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: TriviaColors.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: TriviaColors.textPrimary,
                      unselectedLabelColor: Colors.white70,
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(
                          child: Semantics(
                            label: l10n.rankingTab,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.leaderboard, size: 20),
                                const SizedBox(width: 8),
                                Text(l10n.rankingTab),
                              ],
                            ),
                          ),
                        ),
                        Tab(
                          child: Semantics(
                            label: l10n.achievementsTab,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.emoji_events, size: 20),
                                const SizedBox(width: 8),
                                Text(l10n.achievementsTab),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // TabBarView
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildRankingTab(ref, l10n),
                        _buildAchievementsTab(ref, l10n),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestScoreCard(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final bestScoreAsync = ref.watch(bestScoreProvider);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TriviaColors.primary, TriviaColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TriviaColors.primary.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Semantics(
        label: l10n.bestScoreLabel,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events,
              color: TriviaColors.accent,
              size: 40,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.bestScore,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                bestScoreAsync.when(
                  data: (score) => Text(
                    '$score',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  loading: () => const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  error: (_, __) => const Text(
                    '0',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingTab(WidgetRef ref, AppLocalizations l10n) {
    final rankingAsync = ref.watch(rankingProvider);
    
    return rankingAsync.when(
      data: (records) => RankingList(records: records),
      loading: () => const Center(
        child: CircularProgressIndicator(color: TriviaColors.accent),
      ),
      error: (error, _) => Center(
        child: Text(
          'Error: $error',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAchievementsTab(WidgetRef ref, AppLocalizations l10n) {
    final achievementsAsync = ref.watch(achievementsProvider);
    
    return achievementsAsync.when(
      data: (achievements) {
        final unlocked = achievements.where((a) => a.isUnlocked).length;
        final total = achievements.length;
        
        return SingleChildScrollView(
          child: Column(
            children: [
              // Progreso de logros
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.workspace_premium,
                        color: TriviaColors.accent,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$unlocked / $total ${l10n.achievementsUnlocked}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: total > 0 ? unlocked / total : 0,
                                backgroundColor: Colors.white.withValues(alpha: 0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  TriviaColors.accent,
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Grid de logros
              AchievementsGrid(achievements: achievements),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: TriviaColors.accent),
      ),
      error: (error, _) => Center(
        child: Text(
          'Error: $error',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

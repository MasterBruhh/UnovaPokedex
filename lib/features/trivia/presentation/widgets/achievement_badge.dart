import 'package:flutter/material.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../domain/entities/achievement.dart';
import '../../theme/trivia_colors.dart';

/// Widget que muestra un badge de logro individual.
class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final double size;
  final bool showLabel;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.size = 80,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = _getLocalizedName(l10n);
    
    return Semantics(
      label: achievement.isUnlocked 
          ? 'Logro desbloqueado: $name' 
          : 'Logro bloqueado: $name',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: achievement.isUnlocked
                  ? const LinearGradient(
                      colors: [TriviaColors.accent, TriviaColors.accentLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: achievement.isUnlocked ? null : Colors.grey[700],
              boxShadow: achievement.isUnlocked
                  ? [
                      BoxShadow(
                        color: TriviaColors.accent.withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              IconData(achievement.iconCode, fontFamily: 'MaterialIcons'),
              size: size * 0.5,
              color: achievement.isUnlocked ? TriviaColors.textPrimary : Colors.grey[500],
            ),
          ),
          if (showLabel) ...[
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: achievement.isUnlocked ? Colors.white : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  String _getLocalizedName(AppLocalizations l10n) {
    switch (achievement.id) {
      case 'first_game':
        return l10n.achievementFirstGame;
      case 'score_5':
        return l10n.achievementScore5;
      case 'score_10':
        return l10n.achievementScore10;
      case 'score_25':
        return l10n.achievementScore25;
      case 'score_50':
        return l10n.achievementScore50;
      case 'score_100':
        return l10n.achievementScore100;
      default:
        return achievement.nameKey;
    }
  }
}

/// Lista horizontal de logros con scroll
class AchievementsList extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementsList({
    super.key,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: achievements.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return AchievementBadge(
            achievement: achievements[index],
            size: 70,
          );
        },
      ),
    );
  }
}

/// Grid de logros
class AchievementsGrid extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementsGrid({
    super.key,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return AchievementBadge(
          achievement: achievements[index],
          size: 70,
        );
      },
    );
  }
}

/// Popup de nuevo logro desbloqueado
class NewAchievementDialog extends StatelessWidget {
  final Achievement achievement;

  const NewAchievementDialog({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF2D2D44)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: TriviaColors.accent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.newAchievement,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: TriviaColors.accent,
              ),
            ),
            const SizedBox(height: 24),
            AchievementBadge(
              achievement: achievement,
              size: 100,
            ),
            const SizedBox(height: 16),
            Text(
              _getLocalizedDescription(l10n),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: TriviaColors.accent,
                foregroundColor: TriviaColors.textPrimary,
              ),
              child: Text(l10n.continueButton),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedDescription(AppLocalizations l10n) {
    switch (achievement.id) {
      case 'first_game':
        return l10n.achievementFirstGameDesc;
      case 'score_5':
        return l10n.achievementScore5Desc;
      case 'score_10':
        return l10n.achievementScore10Desc;
      case 'score_25':
        return l10n.achievementScore25Desc;
      case 'score_50':
        return l10n.achievementScore50Desc;
      case 'score_100':
        return l10n.achievementScore100Desc;
      default:
        return achievement.descriptionKey;
    }
  }
}

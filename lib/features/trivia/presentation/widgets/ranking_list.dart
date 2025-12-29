import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../domain/entities/game_record.dart';
import '../../theme/trivia_colors.dart';

/// Widget que muestra un item del ranking
class RankingItem extends StatelessWidget {
  final GameRecord record;
  final int position;

  const RankingItem({
    super.key,
    required this.record,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Semantics(
      label: 'Posición $position, ${record.score} puntos',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: position <= 3
              ? Border.all(color: _getMedalColor(), width: 2)
              : null,
        ),
        child: Row(
          children: [
            // Posición
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getMedalColor(),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: position <= 3
                    ? Icon(
                        _getMedalIcon(),
                        color: Colors.white,
                        size: 24,
                      )
                    : Text(
                        '$position',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // Puntuación
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${record.score} pts',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    dateFormat.format(record.playedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Icono de Pokéball
            const Icon(
              Icons.catching_pokemon,
              color: TriviaColors.accent,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (position) {
      case 1:
        return const Color(0xFF4A3C1A); // Dorado oscuro
      case 2:
        return const Color(0xFF3A3A3A); // Plateado oscuro
      case 3:
        return const Color(0xFF3D2A1A); // Bronce oscuro
      default:
        return Colors.white.withValues(alpha: 0.1);
    }
  }

  Color _getMedalColor() {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700); // Oro
      case 2:
        return const Color(0xFFC0C0C0); // Plata
      case 3:
        return const Color(0xFFCD7F32); // Bronce
      default:
        return TriviaColors.secondary;
    }
  }

  IconData _getMedalIcon() {
    switch (position) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.military_tech;
      case 3:
        return Icons.workspace_premium;
      default:
        return Icons.star;
    }
  }
}

/// Lista completa de ranking
class RankingList extends StatelessWidget {
  final List<GameRecord> records;

  const RankingList({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noRankingYet,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.playToSeeRanking,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: records.length,
      itemBuilder: (context, index) {
        return RankingItem(
          record: records[index],
          position: index + 1,
        );
      },
    );
  }
}

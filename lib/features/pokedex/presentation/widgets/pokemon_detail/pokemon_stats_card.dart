import 'package:flutter/material.dart';
import '../../../../../core/config/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/pokemon_detail.dart';

/// Tarjeta que muestra las estadísticas base del Pokémon
class PokemonStatsCard extends StatelessWidget {
  const PokemonStatsCard({
    super.key,
    required this.stats,
  });

  final List<PokemonStat> stats;

  @override
  Widget build(BuildContext context) {
    // Calcular estadística máxima para escalar las barras
    int maxStat = 1;
    for (final stat in stats) {
      if (stat.baseStat > maxStat) maxStat = stat.baseStat;
    }

    return Column(
      children: AppConstants.statNamesSpanish.entries.map((entry) {
        final stat = stats.firstWhere(
          (s) => s.name == entry.key,
          orElse: () => PokemonStat(name: entry.key, baseStat: 0),
        );

        final ratio = (stat.baseStat / maxStat).clamp(0.0, 1.0);
        final barColor = stat.baseStat > maxStat * 0.6
            ? AppColors.statHighGreen
            : stat.baseStat > maxStat * 0.3
                ? AppColors.statMediumYellow
                : AppColors.statLowRed;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 92,
                child: Text(
                  entry.value,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: ratio,
                  color: barColor,
                  backgroundColor: Colors.white12,
                  minHeight: 10,
                ),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  '${stat.baseStat}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}


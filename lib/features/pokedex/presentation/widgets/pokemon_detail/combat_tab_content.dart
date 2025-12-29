import 'package:flutter/material.dart';
import '../../../domain/entities/pokemon_detail.dart';
import 'pokemon_info_card.dart';
import 'pokemon_moves_section.dart';
import 'pokemon_stats_card.dart';
import 'stats_radar_chart.dart';

/// Contenido de la pestaña "Combate"
/// Muestra las estadísticas base y los movimientos del Pokémon
class CombatTabContent extends StatelessWidget {
  const CombatTabContent({
    super.key,
    required this.pokemon,
  });

  final PokemonDetail pokemon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Radar Chart de estadísticas
        PokemonInfoCard(
          title: 'Distribución de Estadísticas',
          child: Center(
            child: StatsRadarChart(stats: pokemon.stats),
          ),
        ),
        const SizedBox(height: 16),
        PokemonInfoCard(
          title: 'Estadísticas Base',
          child: PokemonStatsCard(stats: pokemon.stats),
        ),
        const SizedBox(height: 16),
        PokemonInfoCard(
          title: 'Movimientos',
          child: PokemonMovesSection(pokemon: pokemon),
        ),
      ],
    );
  }
}

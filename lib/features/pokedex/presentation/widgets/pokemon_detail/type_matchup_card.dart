import 'package:flutter/material.dart';
import '../../../domain/entities/pokemon_type.dart';
import '../../utils/pokemon_type_colors.dart';
import '../../utils/type_effectiveness.dart';

/// Widget que muestra las debilidades, resistencias e inmunidades de un Pokémon
class TypeMatchupCard extends StatelessWidget {
  const TypeMatchupCard({
    super.key,
    required this.types,
  });

  final List<PokemonType> types;

  @override
  Widget build(BuildContext context) {
    final matchup = TypeEffectiveness.calculateMatchup(types);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Debilidades x4
        if (matchup.doubleWeaknesses.isNotEmpty) ...[
          _buildSection(
            'Muy débil (x4)',
            matchup.doubleWeaknesses,
            Colors.red.shade400,
          ),
          const SizedBox(height: 12),
        ],
        
        // Debilidades x2
        if (matchup.weaknesses.isNotEmpty) ...[
          _buildSection(
            'Débil (x2)',
            matchup.weaknesses,
            Colors.red.shade200,
          ),
          const SizedBox(height: 12),
        ],
        
        // Resistencias x0.5
        if (matchup.resistances.isNotEmpty) ...[
          _buildSection(
            'Resistente (x0.5)',
            matchup.resistances,
            Colors.green.shade200,
          ),
          const SizedBox(height: 12),
        ],
        
        // Resistencias x0.25
        if (matchup.doubleResistances.isNotEmpty) ...[
          _buildSection(
            'Muy resistente (x0.25)',
            matchup.doubleResistances,
            Colors.green.shade300,
          ),
          const SizedBox(height: 12),
        ],
        
        // Inmunidades
        if (matchup.immunities.isNotEmpty) ...[
          _buildSection(
            'Inmune (x0)',
            matchup.immunities,
            Colors.white,
          ),
        ],
        
        // Si no tiene ninguna debilidad o resistencia especial
        if (matchup.weaknesses.isEmpty &&
            matchup.doubleWeaknesses.isEmpty &&
            matchup.resistances.isEmpty &&
            matchup.doubleResistances.isEmpty &&
            matchup.immunities.isEmpty)
          const Text(
            'Este Pokémon tiene efectividad neutral contra todos los tipos.',
            style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
          ),
      ],
    );
  }

  Widget _buildSection(String title, List<PokemonType> types, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: labelColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: labelColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: types.map((type) => _TypeBadge(type: type)).toList(),
        ),
      ],
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final PokemonType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: PokemonTypeColors.getColor(type),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: PokemonTypeColors.getColor(type).withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        type.name.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}

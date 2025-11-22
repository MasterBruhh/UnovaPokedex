import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/pokemon_sprite_utils.dart';
import '../../../../../core/utils/string_extensions.dart';
import '../../../domain/entities/pokemon_detail.dart';
import '../../../domain/entities/pokemon_type.dart';
import '../../utils/pokemon_type_colors.dart';

/// Tarjeta de encabezado que muestra información básica del Pokémon
class PokemonHeaderCard extends StatelessWidget {
  const PokemonHeaderCard({
    super.key,
    required this.pokemon,
  });

  final PokemonDetail pokemon;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardOverlay,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Hero(
              tag: 'pokemon-artwork-${pokemon.id}',
              child: Image.network(
                PokemonSpriteUtils.getArtworkUrl(pokemon.id),
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 100,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              pokemon.name.toTitleCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: pokemon.types
                  .map((type) => _TypeChip(type: type))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                Chip(
                  label: Text('Altura: ${pokemon.height.toStringAsFixed(0)}'),
                  backgroundColor: Colors.white24,
                ),
                Chip(
                  label: Text('Peso: ${pokemon.weight.toStringAsFixed(0)}'),
                  backgroundColor: Colors.white24,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final PokemonType type;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        type.name.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: PokemonTypeColors.getColor(type),
    );
  }
}


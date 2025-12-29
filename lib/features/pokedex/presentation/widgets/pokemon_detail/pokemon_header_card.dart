import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/pokemon_sprite_utils.dart';
import '../../../../../core/utils/string_extensions.dart';
import '../../../domain/entities/pokemon_detail.dart';
import '../../../domain/entities/pokemon_type.dart';
import '../../utils/pokemon_type_colors.dart';

/// Tarjeta de encabezado que muestra información básica del Pokémon
class PokemonHeaderCard extends StatefulWidget {
  const PokemonHeaderCard({
    super.key,
    required this.pokemon,
  });

  final PokemonDetail pokemon;

  @override
  State<PokemonHeaderCard> createState() => _PokemonHeaderCardState();
}

class _PokemonHeaderCardState extends State<PokemonHeaderCard> {
  bool _isShiny = false;

  @override
  Widget build(BuildContext context) {
    final pokemon = widget.pokemon;
    
    return Card(
      color: AppColors.cardOverlay,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Número de Pokédex Nacional
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '#${pokemon.id.toString().padLeft(4, '0')}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Imagen del Pokémon con animación
            Stack(
              alignment: Alignment.center,
              children: [
                Hero(
                  tag: 'pokemon-artwork-${pokemon.id}',
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Image.network(
                      _isShiny
                          ? PokemonSpriteUtils.getShinyArtworkUrl(pokemon.id)
                          : PokemonSpriteUtils.getArtworkUrl(pokemon.id),
                      key: ValueKey(_isShiny),
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 100,
                      ),
                    ),
                  ),
                ),
                // Indicador de shiny
                if (_isShiny)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Switch de Shiny
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: _isShiny ? Colors.amber : Colors.white54,
                ),
                const SizedBox(width: 4),
                Text(
                  'Shiny',
                  style: TextStyle(
                    color: _isShiny ? Colors.amber : Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Switch(
                  value: _isShiny,
                  onChanged: (value) {
                    setState(() {
                      _isShiny = value;
                    });
                  },
                  activeColor: Colors.amber,
                  activeTrackColor: Colors.amber.withOpacity(0.4),
                  inactiveThumbColor: Colors.white54,
                  inactiveTrackColor: Colors.white24,
                ),
              ],
            ),
            const SizedBox(height: 8),
            
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
                _InfoChip(
                  icon: Icons.straighten,
                  label: 'Altura',
                  value: '${(pokemon.height / 10).toStringAsFixed(1)} m',
                ),
                _InfoChip(
                  icon: Icons.fitness_center,
                  label: 'Peso',
                  value: '${(pokemon.weight / 10).toStringAsFixed(1)} kg',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
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


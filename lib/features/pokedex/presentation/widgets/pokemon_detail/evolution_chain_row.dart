import 'package:flutter/material.dart';
import '../../../../../core/utils/pokemon_sprite_utils.dart';
import '../../../domain/entities/evolution_detail.dart';
import '../../../domain/entities/pokemon_detail.dart';

/// Widget que muestra una cadena evolutiva horizontal con condiciones
class EvolutionChainRow extends StatelessWidget {
  const EvolutionChainRow({
    super.key,
    required this.chain,
    required this.currentId,
    required this.onTapSpecies,
    this.evolutionDetails = const [],
  });

  final List<EvolutionNode> chain;
  final int currentId;
  final ValueChanged<String> onTapSpecies;
  final List<EvolutionDetail> evolutionDetails;

  @override
  Widget build(BuildContext context) {
    if (chain.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(chain.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Este es el espacio entre Pokemon - mostrar condición
            final toIndex = (i + 1) ~/ 2;
            if (toIndex < chain.length) {
              final toNode = chain[toIndex];
              return _buildEvolutionArrow(context, toNode.id);
            }
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
            );
          }

          final node = chain[i ~/ 2];
          final isCurrent = node.id == currentId;

          return GestureDetector(
            onTap: () => onTapSpecies(node.name),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white24,
                  radius: 36,
                  child: Image.network(
                    PokemonSpriteUtils.getSpriteUrl(node.spriteId),
                    height: 52,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.catching_pokemon,
                      color: Colors.white54,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  node.name[0].toUpperCase() + node.name.substring(1),
                  style: TextStyle(
                    color: isCurrent ? Colors.white : Colors.white70,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEvolutionArrow(BuildContext context, int evolvedSpeciesId) {
    // Buscar la condición de evolución para esta especie
    final evolutionDetail = evolutionDetails.cast<EvolutionDetail?>().firstWhere(
      (e) => e?.evolvedSpeciesId == evolvedSpeciesId,
      orElse: () => null,
    );

    final condition = evolutionDetail?.getConditionDescription() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (condition.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                condition,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 4),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
        ],
      ),
    );
  }
}
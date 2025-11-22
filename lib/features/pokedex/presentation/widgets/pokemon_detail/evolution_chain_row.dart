import 'package:flutter/material.dart';
import '../../../../../core/utils/pokemon_sprite_utils.dart';
import '../../../domain/entities/pokemon_detail.dart';

/// Widget que muestra una cadena evolutiva horizontal
class EvolutionChainRow extends StatelessWidget {
  const EvolutionChainRow({
    super.key,
    required this.chain,
    required this.currentId,
    required this.onTapSpecies,
  });

  final List<EvolutionNode> chain;
  final int currentId;
  final ValueChanged<String> onTapSpecies;

  @override
  Widget build(BuildContext context) {
    if (chain.isEmpty) return const SizedBox.shrink();

    return Row(
      children: List.generate(chain.length * 2 - 1, (i) {
        if (i.isOdd) {
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
              Hero(
                tag: 'species-${node.id}',
                child: CircleAvatar(
                  backgroundColor: Colors.white24,
                  radius: 36,
                  child: Image.network(
                    PokemonSpriteUtils.getSpriteUrl(node.id),
                    height: 52,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                node.name[0].toUpperCase() + node.name.substring(1),
                style: TextStyle(
                  color: isCurrent ? Colors.white : Colors.white70,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}


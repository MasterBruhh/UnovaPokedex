import 'package:flutter/material.dart';
import '../../../domain/entities/pokemon_detail.dart';
import '../../../domain/usecases/get_evolution_chain.dart';
import 'evolution_chain_row.dart';

/// Widget que muestra la sección de evoluciones con pre-evoluciones y evoluciones futuras
class EvolutionSection extends StatelessWidget {
  const EvolutionSection({
    super.key,
    required this.pokemon,
    required this.evolutionUseCase,
    required this.onTapSpecies,
  });

  final PokemonDetail pokemon;
  final GetEvolutionChain evolutionUseCase;
  final ValueChanged<String> onTapSpecies;

  @override
  Widget build(BuildContext context) {
    final preEvolutions = evolutionUseCase.getPreEvolutions(
      pokemon.speciesId,
      pokemon.evolutionChain,
    );
    final forwardEvolutions = evolutionUseCase.getForwardEvolutions(
      pokemon.speciesId,
      pokemon.evolutionChain,
    );

    // Obtener nodo de especie actual
    final currentNode = pokemon.evolutionChain
        .cast<EvolutionNode?>()
        .firstWhere(
          (node) => node?.id == pokemon.speciesId,
          orElse: () => null,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pre-evoluciones
        if (preEvolutions.length > 1) ...[
          const Text(
            'Pre-evoluciones',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          EvolutionChainRow(
            chain: preEvolutions,
            currentId: pokemon.speciesId,
            onTapSpecies: onTapSpecies,
          ),
          const SizedBox(height: 12),
        ],

        // Evoluciones futuras
        const Text(
          'Evoluciones posibles',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        if (forwardEvolutions.isEmpty)
          const Text(
            'Este Pokémon no tiene evoluciones posteriores.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final chain in forwardEvolutions) ...[
                  EvolutionChainRow(
                    chain: [
                      if (currentNode != null) currentNode,
                      ...chain,
                    ],
                    currentId: pokemon.speciesId,
                    onTapSpecies: onTapSpecies,
                  ),
                  const SizedBox(width: 16),
                ],
              ],
            ),
          ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import '../../../domain/entities/evolution_detail.dart';
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
    this.evolutionDetails = const [],
  });

  final PokemonDetail pokemon;
  final GetEvolutionChain evolutionUseCase;
  final ValueChanged<String> onTapSpecies;
  final List<EvolutionDetail> evolutionDetails;

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
            evolutionDetails: evolutionDetails,
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
        else if (forwardEvolutions.length == 1)
          // Evolución lineal (ej: Charmander > Charmeleon > Charizard)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: EvolutionChainRow(
              chain: [
                if (currentNode != null) currentNode,
                ...forwardEvolutions.first,
              ],
              currentId: pokemon.speciesId,
              onTapSpecies: onTapSpecies,
              evolutionDetails: evolutionDetails,
            ),
          )
        else
          // Evoluciones ramificadas (ej: Eevee > varios)
          // Mostrar verticalmente
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < forwardEvolutions.length; i++) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: EvolutionChainRow(
                    chain: [
                      if (currentNode != null) currentNode,
                      ...forwardEvolutions[i],
                    ],
                    currentId: pokemon.speciesId,
                    onTapSpecies: onTapSpecies,
                    evolutionDetails: evolutionDetails,
                  ),
                ),
                if (i < forwardEvolutions.length - 1)
                  const SizedBox(height: 12),
              ],
            ],
          ),
      ],
    );
  }
}


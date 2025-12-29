import 'package:flutter/material.dart';
import '../../../../../core/utils/string_extensions.dart';
import '../../../domain/entities/pokemon_detail.dart';
import 'pokemon_abilities_card.dart';
import 'pokemon_info_card.dart';
import 'type_matchup_card.dart';

/// Contenido de la pestaña "Descripción"
/// Muestra la descripción del Pokémon, sus habilidades y relaciones de tipo
class DescriptionTabContent extends StatelessWidget {
  const DescriptionTabContent({
    super.key,
    required this.pokemon,
  });

  final PokemonDetail pokemon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pokemon.description.isNotEmpty)
          PokemonInfoCard(
            title: 'Descripción',
            child: Text(
              pokemon.description,
              style: const TextStyle(color: Colors.white, height: 1.5),
            ),
          ),
        if (pokemon.description.isNotEmpty) const SizedBox(height: 16),
        PokemonInfoCard(
          title: 'Habilidades',
          child: PokemonAbilitiesCard(abilities: pokemon.abilities),
        ),
        const SizedBox(height: 16),
        PokemonInfoCard(
          title: 'Efectividad de Tipos',
          child: TypeMatchupCard(types: pokemon.types),
        ),
      ],
    );
  }
}

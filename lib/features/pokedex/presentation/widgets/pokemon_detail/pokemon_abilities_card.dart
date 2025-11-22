import 'package:flutter/material.dart';
import '../../../../../core/utils/string_extensions.dart';
import '../../../domain/entities/pokemon_detail.dart';

/// Tarjeta que muestra las habilidades del Pokémon
class PokemonAbilitiesCard extends StatelessWidget {
  const PokemonAbilitiesCard({
    super.key,
    required this.abilities,
  });

  final List<PokemonAbility> abilities;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: abilities
          .map(
            (ability) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                '• ${ability.name.toDisplayName()}${ability.isHidden ? ' (Oculta)' : ''}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          )
          .toList(),
    );
  }
}


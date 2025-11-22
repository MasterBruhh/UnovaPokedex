import 'package:flutter/material.dart';
import '../../../domain/entities/pokemon_type.dart';
import '../../utils/pokemon_type_colors.dart';

/// Una barra horizontal que muestra los colores de tipo del Pokémon
class TypeColorBar extends StatelessWidget {
  const TypeColorBar({
    super.key,
    required this.types,
  });

  final List<PokemonType> types;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      child: Row(
        children: types
            .map((type) => Expanded(
                  child: Container(
                    color: PokemonTypeColors.getColor(type),
                  ),
                ))
            .toList(),
      ),
    );
  }
}


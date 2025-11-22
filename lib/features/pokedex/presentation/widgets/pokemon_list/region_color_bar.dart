import 'package:flutter/material.dart';
import '../../../domain/entities/pokemon_region.dart';
import '../../utils/pokemon_region_colors.dart';

/// Una barra horizontal que muestra el color de la región del Pokémon
class RegionColorBar extends StatelessWidget {
  const RegionColorBar({
    super.key,
    required this.region,
  });

  final PokemonRegion region;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      color: PokemonRegionColors.getColor(region),
    );
  }
}


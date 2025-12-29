import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/pokemon_sprite_utils.dart';
import '../../../../../core/utils/string_extensions.dart';
import '../../../domain/entities/pokemon_region.dart';
import '../../../domain/entities/pokemon_type.dart';
import 'region_color_bar.dart';
import 'type_color_bar.dart';

/// Un widget que representa el lomo de un libro Pokédex en el estante
class PokedexBookSpine extends StatelessWidget {
  const PokedexBookSpine({
    super.key,
    required this.id,
    required this.name,
    required this.types,
    required this.region,
    required this.onTap,
    this.opacity = 1.0,
  });

  final int id;
  final String name;
  final List<PokemonType> types;
  final PokemonRegion region;
  final VoidCallback onTap;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: InkWell(
        onTap: onTap,
        child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.beige,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.mediumBrown, width: 5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            TypeColorBar(types: types),
            const SizedBox(height: 16),
            Hero(
              tag: 'pokemon-artwork-$id',
              child: Image.network(
                PokemonSpriteUtils.getSpriteUrl(id),
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Icon(
                  Icons.catching_pokemon,
                  size: 60,
                  color: AppColors.mediumBrown,
                ),
              ),
            ),
            Expanded(
              child: RotatedBox(
                quarterTurns: 1,
                child: Center(
                  child: Text(
                    name.toTitleCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              '$id',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            RegionColorBar(region: region),
          ],
        ),
      ),
    )
    );
  }
}


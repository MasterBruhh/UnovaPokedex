import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/pokemon_sprite_utils.dart';
import '../../../../../core/utils/string_extensions.dart';
import '../../../domain/entities/pokemon_region.dart';
import '../../../domain/entities/pokemon_type.dart';
import '../../utils/pokemon_region_colors.dart';
import '../../utils/pokemon_type_colors.dart';

class PokedexListCard extends StatelessWidget {
  const PokedexListCard({
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

  static const double _stripeWidth = 16;
  static const double _radius = 14;
  static const double _height = 68;

  @override
  Widget build(BuildContext context) {
    final regionColor = PokemonRegionColors.getColor(region);

    return Opacity(
      opacity: opacity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.beige,
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius - 0.5),
            child: SizedBox(
              height: _height,
              child: Row(
                children: [
                  SizedBox(
                    width: _stripeWidth,
                    child: Column(
                      children: types
                          .map(
                            (type) => Expanded(
                              child: Container(
                                color: PokemonTypeColors.getColor(type),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'pokemon-artwork-$id',
                            child: Image.network(
                              PokemonSpriteUtils.getSpriteUrl(id),
                              height: 48,
                              width: 48,
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => const Icon(
                                Icons.catching_pokemon,
                                size: 40,
                                color: AppColors.mediumBrown,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              name.toTitleCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                              fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: AppColors.darkBrown,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: _stripeWidth,
                    color: regionColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}

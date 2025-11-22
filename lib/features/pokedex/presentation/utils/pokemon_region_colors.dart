import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/pokemon_region.dart';

/// Clase utilitaria para colores de regiones de Pokémon
class PokemonRegionColors {
  // Constructor privado para prevenir instanciación
  PokemonRegionColors._();

  /// Retorna el color para una región de Pokémon dada
  static Color getColor(PokemonRegion region) {
    switch (region) {
      case PokemonRegion.kanto:
        return AppColors.regionKanto;
      case PokemonRegion.johto:
        return AppColors.regionJohto;
      case PokemonRegion.hoenn:
        return AppColors.regionHoenn;
      case PokemonRegion.sinnoh:
        return AppColors.regionSinnoh;
      case PokemonRegion.unova:
        return AppColors.regionUnova;
      case PokemonRegion.kalos:
        return AppColors.regionKalos;
      case PokemonRegion.alola:
        return AppColors.regionAlola;
      case PokemonRegion.galar:
        return AppColors.regionGalar;
      case PokemonRegion.paldea:
        return AppColors.regionPaldea;
      case PokemonRegion.hisui:
        return AppColors.regionHisui;
    }
  }
}


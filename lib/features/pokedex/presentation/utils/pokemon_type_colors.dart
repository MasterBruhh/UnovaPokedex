import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/pokemon_type.dart';

/// Clase utilitaria para colores de tipos de Pokémon
class PokemonTypeColors {
  // Constructor privado para prevenir instanciación
  PokemonTypeColors._();

  /// Retorna el color para un tipo de Pokémon dado
  static Color getColor(PokemonType type) {
    switch (type) {
      case PokemonType.normal:
        return AppColors.typeNormal;
      case PokemonType.fire:
        return AppColors.typeFire;
      case PokemonType.water:
        return AppColors.typeWater;
      case PokemonType.electric:
        return AppColors.typeElectric;
      case PokemonType.grass:
        return AppColors.typeGrass;
      case PokemonType.ice:
        return AppColors.typeIce;
      case PokemonType.fighting:
        return AppColors.typeFighting;
      case PokemonType.poison:
        return AppColors.typePoison;
      case PokemonType.ground:
        return AppColors.typeGround;
      case PokemonType.flying:
        return AppColors.typeFlying;
      case PokemonType.psychic:
        return AppColors.typePsychic;
      case PokemonType.bug:
        return AppColors.typeBug;
      case PokemonType.rock:
        return AppColors.typeRock;
      case PokemonType.ghost:
        return AppColors.typeGhost;
      case PokemonType.dragon:
        return AppColors.typeDragon;
      case PokemonType.dark:
        return AppColors.typeDark;
      case PokemonType.steel:
        return AppColors.typeSteel;
      case PokemonType.fairy:
        return AppColors.typeFairy;
    }
  }
}


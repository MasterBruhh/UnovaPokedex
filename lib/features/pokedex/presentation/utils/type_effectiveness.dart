import '../../domain/entities/pokemon_type.dart';

/// Clase que calcula las efectividades de tipo para un Pokémon
class TypeEffectiveness {
  TypeEffectiveness._();

  /// Tabla de efectividad de tipos (atacante -> defensor -> multiplicador)
  /// 0 = inmune, 0.5 = resistente, 2 = débil
  static const Map<PokemonType, Map<PokemonType, double>> _typeChart = {
    PokemonType.normal: {
      PokemonType.rock: 0.5,
      PokemonType.ghost: 0,
      PokemonType.steel: 0.5,
    },
    PokemonType.fire: {
      PokemonType.fire: 0.5,
      PokemonType.water: 0.5,
      PokemonType.grass: 2,
      PokemonType.ice: 2,
      PokemonType.bug: 2,
      PokemonType.rock: 0.5,
      PokemonType.dragon: 0.5,
      PokemonType.steel: 2,
    },
    PokemonType.water: {
      PokemonType.fire: 2,
      PokemonType.water: 0.5,
      PokemonType.grass: 0.5,
      PokemonType.ground: 2,
      PokemonType.rock: 2,
      PokemonType.dragon: 0.5,
    },
    PokemonType.electric: {
      PokemonType.water: 2,
      PokemonType.electric: 0.5,
      PokemonType.grass: 0.5,
      PokemonType.ground: 0,
      PokemonType.flying: 2,
      PokemonType.dragon: 0.5,
    },
    PokemonType.grass: {
      PokemonType.fire: 0.5,
      PokemonType.water: 2,
      PokemonType.grass: 0.5,
      PokemonType.poison: 0.5,
      PokemonType.ground: 2,
      PokemonType.flying: 0.5,
      PokemonType.bug: 0.5,
      PokemonType.rock: 2,
      PokemonType.dragon: 0.5,
      PokemonType.steel: 0.5,
    },
    PokemonType.ice: {
      PokemonType.fire: 0.5,
      PokemonType.water: 0.5,
      PokemonType.grass: 2,
      PokemonType.ice: 0.5,
      PokemonType.ground: 2,
      PokemonType.flying: 2,
      PokemonType.dragon: 2,
      PokemonType.steel: 0.5,
    },
    PokemonType.fighting: {
      PokemonType.normal: 2,
      PokemonType.ice: 2,
      PokemonType.poison: 0.5,
      PokemonType.flying: 0.5,
      PokemonType.psychic: 0.5,
      PokemonType.bug: 0.5,
      PokemonType.rock: 2,
      PokemonType.ghost: 0,
      PokemonType.dark: 2,
      PokemonType.steel: 2,
      PokemonType.fairy: 0.5,
    },
    PokemonType.poison: {
      PokemonType.grass: 2,
      PokemonType.poison: 0.5,
      PokemonType.ground: 0.5,
      PokemonType.rock: 0.5,
      PokemonType.ghost: 0.5,
      PokemonType.steel: 0,
      PokemonType.fairy: 2,
    },
    PokemonType.ground: {
      PokemonType.fire: 2,
      PokemonType.electric: 2,
      PokemonType.grass: 0.5,
      PokemonType.poison: 2,
      PokemonType.flying: 0,
      PokemonType.bug: 0.5,
      PokemonType.rock: 2,
      PokemonType.steel: 2,
    },
    PokemonType.flying: {
      PokemonType.electric: 0.5,
      PokemonType.grass: 2,
      PokemonType.fighting: 2,
      PokemonType.bug: 2,
      PokemonType.rock: 0.5,
      PokemonType.steel: 0.5,
    },
    PokemonType.psychic: {
      PokemonType.fighting: 2,
      PokemonType.poison: 2,
      PokemonType.psychic: 0.5,
      PokemonType.dark: 0,
      PokemonType.steel: 0.5,
    },
    PokemonType.bug: {
      PokemonType.fire: 0.5,
      PokemonType.grass: 2,
      PokemonType.fighting: 0.5,
      PokemonType.poison: 0.5,
      PokemonType.flying: 0.5,
      PokemonType.psychic: 2,
      PokemonType.ghost: 0.5,
      PokemonType.dark: 2,
      PokemonType.steel: 0.5,
      PokemonType.fairy: 0.5,
    },
    PokemonType.rock: {
      PokemonType.fire: 2,
      PokemonType.ice: 2,
      PokemonType.fighting: 0.5,
      PokemonType.ground: 0.5,
      PokemonType.flying: 2,
      PokemonType.bug: 2,
      PokemonType.steel: 0.5,
    },
    PokemonType.ghost: {
      PokemonType.normal: 0,
      PokemonType.psychic: 2,
      PokemonType.ghost: 2,
      PokemonType.dark: 0.5,
    },
    PokemonType.dragon: {
      PokemonType.dragon: 2,
      PokemonType.steel: 0.5,
      PokemonType.fairy: 0,
    },
    PokemonType.dark: {
      PokemonType.fighting: 0.5,
      PokemonType.psychic: 2,
      PokemonType.ghost: 2,
      PokemonType.dark: 0.5,
      PokemonType.fairy: 0.5,
    },
    PokemonType.steel: {
      PokemonType.fire: 0.5,
      PokemonType.water: 0.5,
      PokemonType.electric: 0.5,
      PokemonType.ice: 2,
      PokemonType.rock: 2,
      PokemonType.steel: 0.5,
      PokemonType.fairy: 2,
    },
    PokemonType.fairy: {
      PokemonType.fire: 0.5,
      PokemonType.fighting: 2,
      PokemonType.poison: 0.5,
      PokemonType.dragon: 2,
      PokemonType.dark: 2,
      PokemonType.steel: 0.5,
    },
  };

  /// Calcula la efectividad de un tipo atacante contra un tipo defensor
  static double getEffectiveness(PokemonType attacker, PokemonType defender) {
    return _typeChart[attacker]?[defender] ?? 1.0;
  }

  /// Calcula las debilidades, resistencias e inmunidades de un Pokémon basado en sus tipos
  static TypeMatchup calculateMatchup(List<PokemonType> defenderTypes) {
    final Map<PokemonType, double> multipliers = {};

    // Inicializar todos los tipos con multiplicador 1
    for (final type in PokemonType.values) {
      multipliers[type] = 1.0;
    }

    // Calcular multiplicadores combinados para cada tipo atacante
    for (final attackerType in PokemonType.values) {
      double combined = 1.0;
      for (final defenderType in defenderTypes) {
        combined *= getEffectiveness(attackerType, defenderType);
      }
      multipliers[attackerType] = combined;
    }

    // Clasificar los tipos según su efectividad
    final List<PokemonType> weaknesses = [];
    final List<PokemonType> resistances = [];
    final List<PokemonType> immunities = [];
    final List<PokemonType> doubleWeaknesses = [];
    final List<PokemonType> doubleResistances = [];

    multipliers.forEach((type, multiplier) {
      if (multiplier == 0) {
        immunities.add(type);
      } else if (multiplier >= 4) {
        doubleWeaknesses.add(type);
      } else if (multiplier >= 2) {
        weaknesses.add(type);
      } else if (multiplier <= 0.25) {
        doubleResistances.add(type);
      } else if (multiplier <= 0.5) {
        resistances.add(type);
      }
    });

    return TypeMatchup(
      weaknesses: weaknesses,
      doubleWeaknesses: doubleWeaknesses,
      resistances: resistances,
      doubleResistances: doubleResistances,
      immunities: immunities,
    );
  }
}

/// Clase que representa las relaciones de tipo de un Pokémon
class TypeMatchup {
  const TypeMatchup({
    required this.weaknesses,
    required this.doubleWeaknesses,
    required this.resistances,
    required this.doubleResistances,
    required this.immunities,
  });

  final List<PokemonType> weaknesses;
  final List<PokemonType> doubleWeaknesses;
  final List<PokemonType> resistances;
  final List<PokemonType> doubleResistances;
  final List<PokemonType> immunities;
}

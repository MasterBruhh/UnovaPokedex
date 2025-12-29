import 'package:equatable/equatable.dart';
import 'pokemon_type.dart';

/// Entidad de dominio que representa información detallada del Pokémon
class PokemonDetail extends Equatable {
  const PokemonDetail({
    required this.id,
    required this.speciesId,
    required this.evolutionChainId,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.abilities,
    required this.stats,
    required this.description,
    required this.evolutionChain,
    required this.moves,
    required this.tmMoves,
    required this.tutorMoves,
    required this.eggMoves,
    this.formSuffix,
  });

  final int id;
  final int speciesId;
  final int evolutionChainId;
  final String name;
  final double height;
  final double weight;
  final List<PokemonType> types;
  final List<PokemonAbility> abilities;
  final List<PokemonStat> stats;
  final String description;
  final List<EvolutionNode> evolutionChain;
  final List<PokemonMove> moves; // Movimientos por nivel
  final List<PokemonMove> tmMoves; // Movimientos por TM/HM
  final List<PokemonMove> tutorMoves; // Movimientos por tutor
  final List<PokemonMove> eggMoves; // Movimientos por huevo
  final String? formSuffix; // Sufijo de forma regional (ej: "alola", "galar")

  /// Verifica si es una forma regional
  bool get isRegionalForm => formSuffix != null && 
      (formSuffix == 'alola' || formSuffix == 'galar' || formSuffix == 'hisui' || formSuffix == 'paldea');

  /// Obtiene el nombre base sin el sufijo de forma
  String get baseName {
    if (formSuffix == null) return name;
    return name.replaceAll('-$formSuffix', '');
  }

  @override
  List<Object?> get props => [
        id,
        speciesId,
        evolutionChainId,
        name,
        height,
        weight,
        types,
        abilities,
        stats,
        description,
        evolutionChain,
        moves,
        tmMoves,
        tutorMoves,
        eggMoves,
        formSuffix,
      ];
}

/// Información de habilidad del Pokémon
class PokemonAbility extends Equatable {
  const PokemonAbility({
    required this.name,
    required this.isHidden,
  });

  final String name;
  final bool isHidden;

  @override
  List<Object?> get props => [name, isHidden];
}

/// Información de estadística del Pokémon
class PokemonStat extends Equatable {
  const PokemonStat({
    required this.name,
    required this.baseStat,
  });

  final String name;
  final int baseStat;

  @override
  List<Object?> get props => [name, baseStat];
}

/// Información de movimiento del Pokémon
class PokemonMove extends Equatable {
  const PokemonMove({
    required this.moveId,
    required this.level,
    required this.name,
  });

  final int moveId;
  final int level;
  final String name;

  @override
  List<Object?> get props => [moveId, level, name];
}

/// Nodo de cadena evolutiva
class EvolutionNode extends Equatable {
  const EvolutionNode({
    required this.id,
    required this.name,
    this.evolvesFromId,
    this.pokemonId, // ID del pokémon específico (para formas regionales)
  });

  final int id; // ID de la especie
  final String name;
  final int? evolvesFromId;
  final int? pokemonId; // Puede ser diferente del id para formas regionales
  
  /// Obtiene el ID a usar para sprites (pokemonId si existe, sino id)
  int get spriteId => pokemonId ?? id;

  @override
  List<Object?> get props => [id, name, evolvesFromId, pokemonId];
}


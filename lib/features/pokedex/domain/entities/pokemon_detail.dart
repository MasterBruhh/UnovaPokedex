import 'package:equatable/equatable.dart';
import 'pokemon_type.dart';

/// Entidad de dominio que representa información detallada del Pokémon
class PokemonDetail extends Equatable {
  const PokemonDetail({
    required this.id,
    required this.speciesId,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.abilities,
    required this.stats,
    required this.description,
    required this.evolutionChain,
    required this.moves,
  });

  final int id;
  final int speciesId;
  final String name;
  final double height;
  final double weight;
  final List<PokemonType> types;
  final List<PokemonAbility> abilities;
  final List<PokemonStat> stats;
  final String description;
  final List<EvolutionNode> evolutionChain;
  final List<PokemonMove> moves;

  @override
  List<Object?> get props => [
        id,
        speciesId,
        name,
        height,
        weight,
        types,
        abilities,
        stats,
        description,
        evolutionChain,
        moves,
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
  });

  final int id;
  final String name;
  final int? evolvesFromId;

  @override
  List<Object?> get props => [id, name, evolvesFromId];
}


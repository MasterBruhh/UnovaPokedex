import '../../../../core/utils/string_extensions.dart';
import '../../domain/entities/pokemon_detail.dart';
import '../../domain/entities/pokemon_type.dart';

/// Objeto de Transferencia de Datos para información detallada del Pokémon
class PokemonDetailDto {
  const PokemonDetailDto({
    required this.id,
    required this.speciesId,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.abilities,
    required this.stats,
    required this.description,
    required this.speciesChain,
    required this.moves,
  });

  final int id;
  final int speciesId;
  final String name;
  final double height;
  final double weight;
  final List<PokemonType> types;
  final List<PokemonAbilityDto> abilities;
  final List<PokemonStatDto> stats;
  final String description;
  final List<PokemonSpeciesNodeDto> speciesChain;
  final List<PokemonMoveDto> moves;

  /// Crea un DTO desde la respuesta JSON
  factory PokemonDetailDto.fromJson(Map<String, dynamic> json) {
    final types = (json['pokemon_v2_pokemontypes'] as List? ?? [])
        .map((type) => type['pokemon_v2_type']?['name'] as String?)
        .whereType<String>()
        .map((name) => PokemonType.fromString(name))
        .toList();

    final abilities = (json['pokemon_v2_pokemonabilities'] as List? ?? [])
        .map((ability) =>
            PokemonAbilityDto.fromJson((ability as Map).cast<String, dynamic>()))
        .toList();

    final stats = (json['pokemon_v2_pokemonstats'] as List? ?? [])
        .map((stat) =>
            PokemonStatDto.fromJson((stat as Map).cast<String, dynamic>()))
        .toList();

    final spec = (json['pokemon_v2_pokemonspecy'] as Map<String, dynamic>?) ?? {};
    final speciesId = spec['id'] as int? ?? json['id'] as int;

    final flavors = (spec['pokemon_v2_pokemonspeciesflavortexts'] as List? ?? [])
        .map((entry) => entry['flavor_text'] as String?)
        .whereType<String>()
        .map((text) => text.cleanApiText())
        .where((text) => text.isNotEmpty)
        .toList();
    final description = flavors.isNotEmpty ? flavors.first : '';

    final speciesChain = (spec['pokemon_v2_evolutionchain']?['pokemon_v2_pokemonspecies']
                as List? ??
            [])
        .map((node) =>
            PokemonSpeciesNodeDto.fromJson((node as Map).cast<String, dynamic>()))
        .toList();

    final moves = <PokemonMoveDto>[];
    final seenMoves = <int>{};
    for (final move in json['pokemon_v2_pokemonmoves'] as List? ?? []) {
      final parsed =
          PokemonMoveDto.fromJson((move as Map).cast<String, dynamic>());
      if (seenMoves.add(parsed.moveId)) {
        moves.add(parsed);
      }
    }

    return PokemonDetailDto(
      id: json['id'] as int,
      name: json['name'] as String,
      height: (json['height'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
      types: types,
      abilities: abilities,
      stats: stats,
      description: description,
      speciesChain: speciesChain,
      moves: moves,
      speciesId: speciesId,
    );
  }

  /// Convierte DTO a entidad de dominio
  PokemonDetail toDomain() {
    return PokemonDetail(
      id: id,
      speciesId: speciesId,
      name: name,
      height: height,
      weight: weight,
      types: types,
      abilities: abilities.map((a) => a.toDomain()).toList(),
      stats: stats.map((s) => s.toDomain()).toList(),
      description: description,
      evolutionChain: speciesChain.map((n) => n.toDomain()).toList(),
      moves: moves.map((m) => m.toDomain()).toList(),
    );
  }
}

/// DTO para habilidad del Pokémon
class PokemonAbilityDto {
  const PokemonAbilityDto({
    required this.name,
    required this.isHidden,
  });

  final String name;
  final bool isHidden;

  factory PokemonAbilityDto.fromJson(Map<String, dynamic> json) {
    final abilityName =
        (json['pokemon_v2_ability']?['name'] as String? ?? '').replaceAll('-', ' ');
    return PokemonAbilityDto(
      name: abilityName,
      isHidden: json['is_hidden'] == true,
    );
  }

  PokemonAbility toDomain() {
    return PokemonAbility(name: name, isHidden: isHidden);
  }
}

/// DTO para estadística del Pokémon
class PokemonStatDto {
  const PokemonStatDto({
    required this.name,
    required this.baseStat,
  });

  final String name;
  final int baseStat;

  factory PokemonStatDto.fromJson(Map<String, dynamic> json) {
    return PokemonStatDto(
      name: (json['pokemon_v2_stat']?['name'] as String?) ?? '',
      baseStat: (json['base_stat'] ?? 0) as int,
    );
  }

  PokemonStat toDomain() {
    return PokemonStat(name: name, baseStat: baseStat);
  }
}

/// DTO para movimiento del Pokémon
class PokemonMoveDto {
  const PokemonMoveDto({
    required this.moveId,
    required this.level,
    required this.name,
  });

  final int moveId;
  final int level;
  final String name;

  factory PokemonMoveDto.fromJson(Map<String, dynamic> json) {
    return PokemonMoveDto(
      moveId: (json['move_id'] ?? -1) as int,
      level: (json['level'] ?? 0) as int,
      name: ((json['pokemon_v2_move']?['name'] as String?) ?? '')
          .replaceAll('-', ' '),
    );
  }

  PokemonMove toDomain() {
    return PokemonMove(moveId: moveId, level: level, name: name);
  }
}

/// DTO para nodo de especie de Pokémon en cadena evolutiva
class PokemonSpeciesNodeDto {
  const PokemonSpeciesNodeDto({
    required this.id,
    required this.name,
    this.evolvesFromSpeciesId,
  });

  final int id;
  final String name;
  final int? evolvesFromSpeciesId;

  factory PokemonSpeciesNodeDto.fromJson(Map<String, dynamic> json) {
    return PokemonSpeciesNodeDto(
      id: json['id'] as int,
      name: json['name'] as String,
      evolvesFromSpeciesId: json['evolves_from_species_id'] as int?,
    );
  }

  EvolutionNode toDomain() {
    return EvolutionNode(
      id: id,
      name: name,
      evolvesFromId: evolvesFromSpeciesId,
    );
  }
}

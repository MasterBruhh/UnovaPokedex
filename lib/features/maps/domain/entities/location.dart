import 'package:equatable/equatable.dart';

/// Modelo que representa un Pokémon encontrado en una ubicación
class PokemonEncounter extends Equatable {
  /// ID del Pokémon
  final int id;
  
  /// Nombre del Pokémon
  final String name;
  
  /// Nivel mínimo de encuentro
  final int minLevel;
  
  /// Nivel máximo de encuentro
  final int maxLevel;
  
  /// Rareza del encuentro (0-100)
  final int rarity;
  
  /// Método de encuentro (Walking, Surfing, Fishing, etc.)
  final String encounterMethod;
  
  /// Versión del juego
  final String version;

  const PokemonEncounter({
    required this.id,
    required this.name,
    required this.minLevel,
    required this.maxLevel,
    required this.rarity,
    required this.encounterMethod,
    required this.version,
  });

  /// Nombre formateado para mostrar (Primera letra mayúscula)
  String get displayName {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  /// Rango de niveles formateado
  String get levelRange {
    if (minLevel == maxLevel) return 'Lv. $minLevel';
    return 'Lv. $minLevel-$maxLevel';
  }

  /// Rareza formateada como porcentaje
  String get rarityPercentage => '$rarity%';

  /// URL del sprite oficial del Pokémon desde PokeAPI
  String get spriteUrl {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
  }

  factory PokemonEncounter.fromJson(Map<String, dynamic> json) {
    return PokemonEncounter(
      id: json['pokemon_v2_pokemon']?['id'] ?? 0,
      name: json['pokemon_v2_pokemon']?['name'] ?? 'unknown',
      minLevel: json['min_level'] ?? 1,
      maxLevel: json['max_level'] ?? 1,
      rarity: json['pokemon_v2_encounterslot']?['rarity'] ?? 0,
      encounterMethod: json['pokemon_v2_encounterslot']
          ?['pokemon_v2_encountermethod']?['name'] ?? 'unknown',
      version: json['pokemon_v2_version']?['name'] ?? 'unknown',
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        minLevel,
        maxLevel,
        rarity,
        encounterMethod,
        version,
      ];

  @override
  String toString() {
    return 'PokemonEncounter(id: $id, name: $name, levels: $levelRange, rarity: $rarityPercentage)';
  }
}

/// Modelo que representa un área dentro de una ubicación
class LocationArea extends Equatable {
  /// ID del área
  final int id;
  
  /// Nombre del área
  final String name;
  
  /// Lista de encuentros de Pokémon en esta área
  final List<PokemonEncounter> encounters;

  const LocationArea({
    required this.id,
    required this.name,
    required this.encounters,
  });

  /// Nombre formateado del área
  String get displayName {
    if (name.isEmpty) return name;
    // Remover el prefijo de la ubicación si existe
    final parts = name.split('-');
    if (parts.length > 1) {
      return parts.sublist(1).join(' ').split(' ').map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1);
      }).join(' ');
    }
    return name[0].toUpperCase() + name.substring(1);
  }

  /// Obtiene lista única de Pokémon (sin duplicados)
  List<PokemonEncounter> get uniquePokemon {
    final seen = <int>{};
    return encounters.where((encounter) {
      if (seen.contains(encounter.id)) return false;
      seen.add(encounter.id);
      return true;
    }).toList();
  }

  factory LocationArea.fromJson(Map<String, dynamic> json) {
    final encountersJson = json['pokemon_v2_encounters'] as List<dynamic>? ?? [];
    
    return LocationArea(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'unknown',
      encounters: encountersJson
          .map((e) => PokemonEncounter.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, name, encounters];

  @override
  String toString() {
    return 'LocationArea(id: $id, name: $name, encounters: ${encounters.length})';
  }
}

/// Modelo que representa una región de Pokémon
class Region extends Equatable {
  /// ID de la región
  final int id;
  
  /// Nombre de la región
  final String name;

  const Region({
    required this.id,
    required this.name,
  });

  /// Nombre formateado
  String get displayName {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'unknown',
    );
  }

  @override
  List<Object?> get props => [id, name];

  @override
  String toString() => 'Region(id: $id, name: $name)';
}

/// Modelo que representa una ubicación completa con todos sus detalles
class LocationDetail extends Equatable {
  /// ID de la ubicación
  final int id;
  
  /// Nombre de la ubicación
  final String name;
  
  /// Región a la que pertenece
  final Region region;
  
  /// Áreas de la ubicación
  final List<LocationArea> areas;

  const LocationDetail({
    required this.id,
    required this.name,
    required this.region,
    required this.areas,
  });

  /// Nombre formateado
  String get displayName {
    if (name.isEmpty) return name;
    return name.split('-').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  /// Obtiene todos los Pokémon únicos de todas las áreas
  List<PokemonEncounter> get allUniquePokemon {
    final allPokemon = areas.expand((area) => area.encounters).toList();
    final seen = <int>{};
    
    return allPokemon.where((encounter) {
      if (seen.contains(encounter.id)) return false;
      seen.add(encounter.id);
      return true;
    }).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
  }

  /// Cuenta total de Pokémon diferentes
  int get totalUniquePokemonCount => allUniquePokemon.length;

  factory LocationDetail.fromJson(Map<String, dynamic> json) {
    final areasJson = json['pokemon_v2_locationareas'] as List<dynamic>? ?? [];
    final regionJson = json['pokemon_v2_region'] as Map<String, dynamic>? ?? {};
    
    return LocationDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'unknown',
      region: Region.fromJson(regionJson),
      areas: areasJson
          .map((e) => LocationArea.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, name, region, areas];

  @override
  String toString() {
    return 'LocationDetail(id: $id, name: $name, region: ${region.name}, areas: ${areas.length}, pokemon: $totalUniquePokemonCount)';
  }
}

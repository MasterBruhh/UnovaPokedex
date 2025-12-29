import '../../domain/entities/evolution_detail.dart';

/// DTO para los detalles de evolución
class EvolutionDetailDto {
  const EvolutionDetailDto({
    required this.evolvedSpeciesId,
    required this.trigger,
    this.minLevel,
    this.minHappiness,
    this.minBeauty,
    this.minAffection,
    this.timeOfDay,
    this.needsOverworldRain = false,
    this.turnUpsideDown = false,
    this.relativePhysicalStats,
    this.genderId,
    this.itemName,
    this.itemId,
    this.heldItemName,
    this.heldItemId,
    this.locationName,
    this.moveName,
    this.moveTypeName,
    this.tradeSpeciesName,
  });

  final int evolvedSpeciesId;
  final String trigger;
  final int? minLevel;
  final int? minHappiness;
  final int? minBeauty;
  final int? minAffection;
  final String? timeOfDay;
  final bool needsOverworldRain;
  final bool turnUpsideDown;
  final int? relativePhysicalStats;
  final int? genderId;
  final String? itemName;
  final int? itemId;
  final String? heldItemName;
  final int? heldItemId;
  final String? locationName;
  final String? moveName;
  final String? moveTypeName;
  final String? tradeSpeciesName;

  factory EvolutionDetailDto.fromJson(Map<String, dynamic> json) {
    // Extraer trigger
    final trigger = json['pokemon_v2_evolutiontrigger']?['name'] as String? ?? 'level-up';

    // Extraer item para evolucionar
    final itemData = json['pokemon_v2_item'] as Map<String, dynamic>?;
    String? itemName;
    int? itemId;
    if (itemData != null) {
      itemId = itemData['id'] as int?;
      final itemNames = itemData['pokemon_v2_itemnames'] as List?;
      if (itemNames != null && itemNames.isNotEmpty) {
        itemName = itemNames.first['name'] as String?;
      }
      itemName ??= (itemData['name'] as String?)?.replaceAll('-', ' ');
    }

    // Extraer held item
    final heldItemData = json['pokemonV2ItemByHeldItemId'] as Map<String, dynamic>?;
    String? heldItemName;
    int? heldItemId;
    if (heldItemData != null) {
      heldItemId = heldItemData['id'] as int?;
      final heldItemNames = heldItemData['pokemon_v2_itemnames'] as List?;
      if (heldItemNames != null && heldItemNames.isNotEmpty) {
        heldItemName = heldItemNames.first['name'] as String?;
      }
      heldItemName ??= (heldItemData['name'] as String?)?.replaceAll('-', ' ');
    }

    // Extraer ubicación
    final locationData = json['pokemon_v2_location'] as Map<String, dynamic>?;
    String? locationName;
    if (locationData != null) {
      final locationNames = locationData['pokemon_v2_locationnames'] as List?;
      if (locationNames != null && locationNames.isNotEmpty) {
        locationName = locationNames.first['name'] as String?;
      }
    }

    // Extraer movimiento requerido
    final moveData = json['pokemon_v2_move'] as Map<String, dynamic>?;
    String? moveName;
    if (moveData != null) {
      final moveNames = moveData['pokemon_v2_movenames'] as List?;
      if (moveNames != null && moveNames.isNotEmpty) {
        moveName = moveNames.first['name'] as String?;
      }
    }

    // Extraer tipo de movimiento
    final moveTypeData = json['pokemon_v2_type'] as Map<String, dynamic>?;
    final moveTypeName = moveTypeData?['name'] as String?;

    // Extraer especie para intercambio
    final tradeSpeciesData = json['pokemonV2PokemonspecyByTradeSpeciesId'] as Map<String, dynamic>?;
    final tradeSpeciesName = tradeSpeciesData?['name'] as String?;

    return EvolutionDetailDto(
      evolvedSpeciesId: json['evolved_species_id'] as int,
      trigger: trigger,
      minLevel: json['min_level'] as int?,
      minHappiness: json['min_happiness'] as int?,
      minBeauty: json['min_beauty'] as int?,
      minAffection: json['min_affection'] as int?,
      timeOfDay: json['time_of_day'] as String?,
      needsOverworldRain: json['needs_overworld_rain'] == true,
      turnUpsideDown: json['turn_upside_down'] == true,
      relativePhysicalStats: json['relative_physical_stats'] as int?,
      genderId: json['gender_id'] as int?,
      itemName: itemName,
      itemId: itemId,
      heldItemName: heldItemName,
      heldItemId: heldItemId,
      locationName: locationName,
      moveName: moveName,
      moveTypeName: moveTypeName,
      tradeSpeciesName: tradeSpeciesName,
    );
  }

  EvolutionDetail toDomain() {
    return EvolutionDetail(
      evolvedSpeciesId: evolvedSpeciesId,
      trigger: trigger,
      minLevel: minLevel,
      minHappiness: minHappiness,
      minBeauty: minBeauty,
      minAffection: minAffection,
      timeOfDay: timeOfDay,
      needsOverworldRain: needsOverworldRain,
      turnUpsideDown: turnUpsideDown,
      relativePhysicalStats: relativePhysicalStats,
      genderId: genderId,
      itemName: itemName,
      itemId: itemId,
      heldItemName: heldItemName,
      heldItemId: heldItemId,
      locationName: locationName,
      moveName: moveName,
      moveTypeName: moveTypeName,
      tradeSpeciesName: tradeSpeciesName,
    );
  }
}

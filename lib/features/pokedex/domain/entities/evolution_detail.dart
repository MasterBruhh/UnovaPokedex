import 'package:equatable/equatable.dart';

/// Representa los detalles de una evolución específica
class EvolutionDetail extends Equatable {
  const EvolutionDetail({
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
  final String trigger; // level-up, trade, use-item, etc.
  final int? minLevel;
  final int? minHappiness;
  final int? minBeauty;
  final int? minAffection;
  final String? timeOfDay; // day, night
  final bool needsOverworldRain;
  final bool turnUpsideDown;
  final int? relativePhysicalStats; // -1, 0, 1 para Tyrogue
  final int? genderId; // 1=female, 2=male
  final String? itemName; // Item usado para evolucionar
  final int? itemId;
  final String? heldItemName; // Item que debe sostener
  final int? heldItemId;
  final String? locationName;
  final String? moveName;
  final String? moveTypeName;
  final String? tradeSpeciesName;

  /// Genera una descripción legible de la condición de evolución
  String getConditionDescription() {
    final conditions = <String>[];

    switch (trigger) {
      case 'level-up':
        if (minLevel != null) {
          conditions.add('Nivel $minLevel');
        } else if (minHappiness != null) {
          conditions.add('Felicidad alta');
        } else if (minBeauty != null) {
          conditions.add('Belleza alta');
        } else if (minAffection != null) {
          conditions.add('Afecto alto');
        } else {
          conditions.add('Subir de nivel');
        }
        break;
      case 'trade':
        conditions.add('Intercambio');
        if (tradeSpeciesName != null) {
          conditions.add('con $tradeSpeciesName');
        }
        break;
      case 'use-item':
        if (itemName != null) {
          conditions.add(itemName!);
        } else {
          conditions.add('Usar objeto');
        }
        break;
      case 'shed':
        conditions.add('Espacio en equipo + Pokéball');
        break;
      default:
        conditions.add('Condición especial');
    }

    // Condiciones adicionales
    if (heldItemName != null) {
      conditions.add('sosteniendo $heldItemName');
    }
    if (timeOfDay == 'day') {
      conditions.add('(día)');
    } else if (timeOfDay == 'night') {
      conditions.add('(noche)');
    }
    if (locationName != null) {
      conditions.add('en $locationName');
    }
    if (moveName != null) {
      conditions.add('conociendo $moveName');
    }
    if (moveTypeName != null) {
      conditions.add('con movimiento tipo $moveTypeName');
    }
    if (needsOverworldRain) {
      conditions.add('mientras llueve');
    }
    if (turnUpsideDown) {
      conditions.add('consola al revés');
    }
    if (genderId == 1) {
      conditions.add('(♀)');
    } else if (genderId == 2) {
      conditions.add('(♂)');
    }
    if (relativePhysicalStats != null) {
      if (relativePhysicalStats == 1) {
        conditions.add('(Ataque > Defensa)');
      } else if (relativePhysicalStats == -1) {
        conditions.add('(Defensa > Ataque)');
      } else {
        conditions.add('(Ataque = Defensa)');
      }
    }

    return conditions.join(' ');
  }

  @override
  List<Object?> get props => [
        evolvedSpeciesId,
        trigger,
        minLevel,
        minHappiness,
        timeOfDay,
        itemName,
        heldItemName,
      ];
}

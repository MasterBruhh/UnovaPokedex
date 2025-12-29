import 'package:equatable/equatable.dart';
import 'pokemon_type.dart';

/// Tipos de formas especiales
enum SpecialFormType {
  mega,
  regional,
  gmax,
  alternate,
}

/// Representa una forma especial de un Pokémon
class PokemonForm extends Equatable {
  const PokemonForm({
    required this.id,
    required this.name,
    required this.formName,
    required this.displayName,
    required this.formType,
    required this.types,
    this.isBattleOnly = false,
    this.abilityName,
    this.itemId,
    this.itemName,
  });

  final int id;
  final String name; // Nombre completo (ej: "charizard-mega-x")
  final String formName; // Nombre de la forma (ej: "mega-x")
  final String displayName; // Nombre para mostrar (ej: "Mega Charizard X")
  final SpecialFormType formType;
  final List<PokemonType> types;
  final bool isBattleOnly;
  final String? abilityName;
  final int? itemId; // ID del item que activa la forma
  final String? itemName; // Nombre del item

  /// Determina el tipo de forma basándose en el nombre
  static SpecialFormType determineFormType(String formName, bool isMega) {
    if (isMega) return SpecialFormType.mega;
    
    final lowerName = formName.toLowerCase();
    if (lowerName.contains('gmax') || lowerName.contains('gigantamax')) {
      return SpecialFormType.gmax;
    }
    if (lowerName.contains('alola') || 
        lowerName.contains('galar') || 
        lowerName.contains('hisui') ||
        lowerName.contains('paldea')) {
      return SpecialFormType.regional;
    }
    return SpecialFormType.alternate;
  }

  /// Obtiene la región de una forma regional
  String? get regionName {
    if (formType != SpecialFormType.regional) return null;
    
    final lowerName = formName.toLowerCase();
    if (lowerName.contains('alola')) return 'Alola';
    if (lowerName.contains('galar')) return 'Galar';
    if (lowerName.contains('hisui')) return 'Hisui';
    if (lowerName.contains('paldea')) return 'Paldea';
    return null;
  }

  @override
  List<Object?> get props => [id, name, formName, formType];
}

import '../../domain/entities/pokemon_form.dart';
import '../../domain/entities/pokemon_type.dart';

/// DTO para una forma alternativa de Pokémon
class PokemonFormDto {
  const PokemonFormDto({
    required this.id,
    required this.name,
    required this.formName,
    required this.displayName,
    required this.isMega,
    required this.isBattleOnly,
    required this.types,
    this.abilityName,
  });

  final int id;
  final String name;
  final String formName;
  final String displayName;
  final bool isMega;
  final bool isBattleOnly;
  final List<PokemonType> types;
  final String? abilityName;

  factory PokemonFormDto.fromJson(Map<String, dynamic> json, Map<String, dynamic> pokemonJson) {
    final formName = json['form_name'] as String? ?? '';
    final name = pokemonJson['name'] as String? ?? json['name'] as String? ?? '';
    
    // Obtener nombre traducido
    final formNames = json['pokemon_v2_pokemonformnames'] as List? ?? [];
    String displayName = name;
    if (formNames.isNotEmpty) {
      final translatedName = formNames.first['pokemon_name'] as String?;
      final formTranslation = formNames.first['name'] as String?;
      displayName = translatedName ?? formTranslation ?? name;
    }

    // Obtener tipos de la forma o del pokemon
    final formTypes = json['pokemon_v2_pokemonformtypes'] as List?;
    final pokemonTypes = pokemonJson['pokemon_v2_pokemontypes'] as List? ?? [];
    
    List<PokemonType> types;
    if (formTypes != null && formTypes.isNotEmpty) {
      types = formTypes
          .map((t) => t['pokemon_v2_type']?['name'] as String?)
          .whereType<String>()
          .map((n) => PokemonType.fromString(n))
          .toList();
    } else {
      types = pokemonTypes
          .map((t) => t['pokemon_v2_type']?['name'] as String?)
          .whereType<String>()
          .map((n) => PokemonType.fromString(n))
          .toList();
    }

    // Obtener habilidad
    final abilities = pokemonJson['pokemon_v2_pokemonabilities'] as List? ?? [];
    String? abilityName;
    if (abilities.isNotEmpty) {
      final abilityData = abilities.first['pokemon_v2_ability'] as Map<String, dynamic>?;
      if (abilityData != null) {
        final abilityNames = abilityData['pokemon_v2_abilitynames'] as List?;
        if (abilityNames != null && abilityNames.isNotEmpty) {
          abilityName = abilityNames.first['name'] as String?;
        }
        abilityName ??= (abilityData['name'] as String?)?.replaceAll('-', ' ');
      }
    }

    return PokemonFormDto(
      id: pokemonJson['id'] as int,
      name: name,
      formName: formName,
      displayName: displayName,
      isMega: json['is_mega'] == true,
      isBattleOnly: json['is_battle_only'] == true,
      types: types,
      abilityName: abilityName,
    );
  }

  PokemonForm toDomain({int? itemId, String? itemName}) {
    return PokemonForm(
      id: id,
      name: name,
      formName: formName,
      displayName: displayName,
      formType: PokemonForm.determineFormType(formName, isMega),
      types: types,
      isBattleOnly: isBattleOnly,
      abilityName: abilityName,
      itemId: itemId,
      itemName: itemName,
    );
  }
}

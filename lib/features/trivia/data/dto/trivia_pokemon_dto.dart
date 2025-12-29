import '../../domain/entities/trivia_pokemon.dart';

/// Data Transfer Object para datos de Pokémon de la API GraphQL.
/// 
/// Esta clase maneja el mapeo entre la respuesta cruda de GraphQL
/// y la entidad de dominio [TriviaPokemon].
class TriviaPokemonDto {
  final int id;
  final String name;
  final String? description;
  final String? spriteUrl;

  const TriviaPokemonDto({
    required this.id,
    required this.name,
    this.description,
    this.spriteUrl,
  });

  /// Crea un TriviaPokemonDto desde una respuesta JSON de GraphQL.
  /// 
  /// Estructura JSON esperada:
  /// ```json
  /// {
  ///   "id": 25,
  ///   "name": "pikachu",
  ///   "pokemon_v2_pokemonsprites": [{"sprites": "..."}],
  ///   "pokemon_v2_pokemonspecy": {
  ///     "pokemon_v2_pokemonspeciesflavortexts": [{"flavor_text": "..."}]
  ///   }
  /// }
  /// ```
  factory TriviaPokemonDto.fromJson(Map<String, dynamic> json) {
    String? description;
    
    // Extraer descripción de los flavor texts de la especie
    final specy = json['pokemon_v2_pokemonspecy'];
    if (specy != null) {
      final flavorTexts = specy['pokemon_v2_pokemonspeciesflavortexts'] as List?;
      if (flavorTexts != null && flavorTexts.isNotEmpty) {
        description = flavorTexts[0]['flavor_text'] as String?;
      }
    }

    return TriviaPokemonDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: description,
      spriteUrl: null, // Se generará desde el ID
    );
  }

  /// Crea un TriviaPokemonDto simple desde una respuesta GraphQL básica.
  /// 
  /// Usado para parsear opciones de Pokémon que no necesitan detalles completos.
  factory TriviaPokemonDto.fromSimpleJson(Map<String, dynamic> json) {
    return TriviaPokemonDto(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  /// Convierte este DTO a una entidad de dominio [TriviaPokemon].
  TriviaPokemon toEntity() {
    return TriviaPokemon.withSpriteUrl(
      id: id,
      name: name,
      description: description,
    );
  }

  /// Convierte una lista de objetos JSON a una lista de TriviaPokemonDto.
  static List<TriviaPokemonDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => TriviaPokemonDto.fromSimpleJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convierte este DTO a JSON (para testing/debugging).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'spriteUrl': spriteUrl,
    };
  }
}

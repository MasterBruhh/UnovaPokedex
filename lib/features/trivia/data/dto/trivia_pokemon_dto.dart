import 'dart:convert';
import '../../domain/entities/trivia_pokemon.dart';

/// Data Transfer Object para datos de Pokémon de la API GraphQL.
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

  factory TriviaPokemonDto.fromJson(Map<String, dynamic> json, {String? descriptionOverride}) {
    final pokemonId = json['id'] as int;

    // 1. Lógica de Descripción (Igual que antes)
    String? finalDescription = descriptionOverride;

    if (finalDescription == null || finalDescription.isEmpty) {
      final specy = json['pokemon_v2_pokemonspecy'];
      if (specy != null) {
        final flavorTexts = specy['pokemon_v2_pokemonspeciesflavortexts'] as List?;

        if (flavorTexts != null && flavorTexts.isNotEmpty) {
          var targetEntry = flavorTexts.firstWhere(
                (entry) => entry['language_id'] == 7,
            orElse: () => null,
          );

          targetEntry ??= flavorTexts.firstWhere(
                (entry) => entry['language_id'] == 9,
            orElse: () => flavorTexts.first,
          );

          if (targetEntry != null) {
            finalDescription = targetEntry['flavor_text'] as String?;
          }
        }
      }
    }

    if (finalDescription != null) {
      finalDescription = finalDescription
          .replaceAll('\n', ' ')
          .replaceAll('\f', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .replaceAll('POKéMON', 'Pokémon')
          .trim();
    }

    // 2. Lógica de Sprites (MEJORADA)
    String? finalSpriteUrl;

    // Intento 1: Leer desde la API (Parseo del JSON string)
    final spritesList = json['pokemon_v2_pokemonsprites'] as List?;
    if (spritesList != null && spritesList.isNotEmpty) {
      final spriteString = spritesList[0]['sprites'];
      if (spriteString != null) {
        try {
          final spriteMap = jsonDecode(spriteString);
          // Intentamos obtener el arte oficial primero, si no el sprite normal
          final other = spriteMap['other'];
          if (other != null && other['official-artwork'] != null) {
            finalSpriteUrl = other['official-artwork']['front_default'];
          }

          if (finalSpriteUrl == null) {
            finalSpriteUrl = spriteMap['front_default'];
          }
        } catch (e) {
          // Si falla el parseo, ignoramos y pasamos al Plan B
        }
      }
    }

    // Intento 2 (PLAN B - INFALIBLE): Construir la URL manualmente usando el ID
    // Esto asegura que la imagen SIEMPRE cargue si tenemos el ID.
    if (finalSpriteUrl == null || finalSpriteUrl.isEmpty) {
      finalSpriteUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonId.png';
    }

    return TriviaPokemonDto(
      id: pokemonId,
      name: json['name'] as String,
      description: finalDescription,
      spriteUrl: finalSpriteUrl,
    );
  }

  /// Crea un TriviaPokemonDto simple
  factory TriviaPokemonDto.fromSimpleJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    // También aplicamos la URL manual aquí para las opciones de respuesta
    return TriviaPokemonDto(
      id: id,
      name: json['name'] as String,
      spriteUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
      description: null,
    );
  }

  TriviaPokemon toEntity() {
    return TriviaPokemon(
      id: id,
      name: _capitalize(name),
      description: description ?? '',
      spriteUrl: spriteUrl ?? '',
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static List<TriviaPokemonDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => TriviaPokemonDto.fromSimpleJson(json as Map<String, dynamic>))
        .toList();
  }
}
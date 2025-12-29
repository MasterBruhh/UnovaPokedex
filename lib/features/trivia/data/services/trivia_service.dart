import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/graphql/graphql_client_provider.dart'; // Ajusta si tu ruta es diferente
import '../../domain/entities/trivia_pokemon.dart';
import '../graphql/trivia_queries.dart';
import '../dto/trivia_pokemon_dto.dart';

class TriviaService {
  final GraphQLClient _client;

  TriviaService(this._client);

  /// Obtiene un Pokémon por su ID (solo datos básicos para opciones)
  Future<TriviaPokemon> fetchPokemonById(int id) async {
    final options = QueryOptions(
      document: gql(getRandomPokemonQuery),
      variables: {'id': id},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['pokemon_v2_pokemon'];
    if (data == null || (data as List).isEmpty) {
      throw Exception('Pokemon not found');
    }

    return TriviaPokemonDto.fromJson(data[0]).toEntity();
  }

  /// Obtiene múltiples Pokémon por una lista de IDs (para opciones incorrectas)
  Future<List<TriviaPokemon>> fetchPokemonByIds(List<int> ids) async {
    final options = QueryOptions(
      document: gql(getPokemonOptionsQuery),
      variables: {'ids': ids},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['pokemon_v2_pokemon'] as List?;
    if (data == null) return [];

    return data
        .map((json) => TriviaPokemonDto.fromJson(json).toEntity())
        .toList();
  }

  /// Obtiene un Pokémon con su descripción en el idioma específico.
  ///
  /// [languageCode]: 'es' para Español (ID 7) o 'en' para Inglés (ID 9).
  Future<TriviaPokemon> fetchPokemonWithDescription(int id, {String languageCode = 'es'}) async {
    final options = QueryOptions(
      document: gql(getPokemonQuestionDataQuery),
      variables: {'id': id},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['pokemon_v2_pokemon'];
    if (data == null || (data as List).isEmpty) {
      throw Exception('Pokemon not found');
    }

    final pokemonData = data[0];

    // --- LÓGICA DE FILTRADO DE IDIOMA ---

    // 1. Determinar el ID del idioma (7=Español, 9=Inglés)
    final targetLanguageId = (languageCode == 'en') ? 9 : 7;

    // 2. Extraer la lista de textos disponibles
    final species = pokemonData['pokemon_v2_pokemonspecy'];
    final flavorTexts = species['pokemon_v2_pokemonspeciesflavortexts'] as List;

    // 3. Buscar el texto que coincida con el idioma seleccionado
    var selectedEntry = flavorTexts.firstWhere(
          (entry) => entry['language_id'] == targetLanguageId,
      orElse: () {
        // Fallback: Si no existe en el idioma pedido, devuelve el primero disponible
        return flavorTexts.isNotEmpty ? flavorTexts.first : null;
      },
    );

    String description = '';
    if (selectedEntry != null) {
      // Limpieza de texto: La API trae caracteres especiales como \n o \f
      description = selectedEntry['flavor_text']
          .toString()
          .replaceAll('\n', ' ')
          .replaceAll('\f', ' ')
          .replaceAll(RegExp(r'\s+'), ' ') // Eliminar espacios dobles
          .trim();
    } else {
      description = (languageCode == 'en')
          ? 'No description available.'
          : 'Descripción no disponible.';
    }

    // 4. Crear el DTO y devolver la entidad con la descripción correcta
    return TriviaPokemonDto.fromJson(pokemonData, descriptionOverride: description).toEntity();
  }
}
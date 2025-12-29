import 'package:graphql_flutter/graphql_flutter.dart';

import '../graphql/trivia_queries.dart';
import '../dto/trivia_pokemon_dto.dart';
import '../../domain/entities/trivia_pokemon.dart';

/// Servicio para manejar todas las llamadas a la API GraphQL de Pokémon.
/// 
/// Este servicio encapsula las interacciones con el cliente GraphQL y
/// proporciona métodos limpios para obtener datos de Pokémon.
class TriviaService {
  final GraphQLClient _client;

  TriviaService(this._client);

  /// Obtiene un único Pokémon por su ID con detalles completos.
  /// 
  /// Retorna una entidad [TriviaPokemon] con nombre, ID, descripción y URL de sprite.
  /// Lanza una excepción si el Pokémon no se encuentra o si la solicitud falla.
  Future<TriviaPokemon> fetchPokemonById(int id) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getPokemonQuestionDataQuery),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception('Error al obtener Pokémon: ${result.exception}');
    }

    final data = result.data;
    if (data == null) {
      throw Exception('No se recibieron datos de la API');
    }

    final pokemonList = data['pokemon_v2_pokemon'] as List;
    if (pokemonList.isEmpty) {
      throw Exception('Pokémon no encontrado con ID: $id');
    }

    final pokemonDto = TriviaPokemonDto.fromJson(pokemonList[0] as Map<String, dynamic>);
    return pokemonDto.toEntity();
  }

  /// Obtiene múltiples Pokémon por sus IDs para generar opciones.
  /// 
  /// Retorna una lista de entidades [TriviaPokemon] con información básica.
  /// Estos se usan como opciones de respuesta en el juego de trivia.
  Future<List<TriviaPokemon>> fetchPokemonByIds(List<int> ids) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getPokemonOptionsQuery),
        variables: {'ids': ids},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception('Error al obtener opciones de Pokémon: ${result.exception}');
    }

    final data = result.data;
    if (data == null) {
      throw Exception('No se recibieron datos de la API');
    }

    final pokemonList = data['pokemon_v2_pokemon'] as List;
    final dtos = TriviaPokemonDto.fromJsonList(pokemonList);
    
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  /// Obtiene un Pokémon con su descripción para preguntas de tipo descripción.
  /// 
  /// Este es un alias para [fetchPokemonById] ya que el query ya incluye
  /// los datos de descripción.
  Future<TriviaPokemon> fetchPokemonWithDescription(int id) async {
    return fetchPokemonById(id);
  }
}

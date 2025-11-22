import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/graphql/graphql_exceptions.dart';
import '../dto/pokemon_detail_dto.dart';
import '../dto/pokemon_summary_dto.dart';
import '../graphql/get_pokemon_detail_query.dart';
import '../graphql/get_pokemon_list_query.dart';

/// Fuente de datos remota para obtener información de Pokémon desde la API GraphQL
class PokedexRemoteDatasource {
  const PokedexRemoteDatasource({required GraphQLClient client})
      : _client = client;

  final GraphQLClient _client;

  /// Obtiene la lista de todos los Pokémon desde la API
  Future<List<PokemonSummaryDto>> fetchPokemonList() async {
    final result = await _client.query(
      QueryOptions(document: gql(getPokemonListQuery)),
    );

    if (result.hasException) {
      throw _handleException(result.exception!);
    }

    final data = result.data?['pokemon_v2_pokemon'] as List? ?? [];
    return data
        .map((json) =>
            PokemonSummaryDto.fromJson((json as Map).cast<String, dynamic>()))
        .toList(growable: false);
  }

  /// Obtiene información detallada para un Pokémon específico
  /// Se debe proporcionar [id] o [name]
  Future<PokemonDetailDto> fetchPokemonDetail({int? id, String? name}) async {
    final where = name != null
        ? {'name': {'_eq': name}}
        : {'id': {'_eq': id}};

    final result = await _client.query(
      QueryOptions(
        document: gql(getPokemonDetailQuery),
        variables: {'where': where},
      ),
    );

    if (result.hasException) {
      throw _handleException(result.exception!);
    }

    final pokemonList = result.data?['pokemon_v2_pokemon'] as List? ?? [];
    if (pokemonList.isEmpty) {
      throw PokemonNotFoundException(name ?? id?.toString());
    }

    return PokemonDetailDto.fromJson(
      (pokemonList.first as Map).cast<String, dynamic>(),
    );
  }

  /// Convierte excepciones de GraphQL a excepciones personalizadas
  Exception _handleException(OperationException exception) {
    if (exception.linkException != null) {
      return const PokedexNetworkException();
    }
    return GraphQLException(
      exception.graphqlErrors.isNotEmpty
          ? exception.graphqlErrors.first.message
          : 'Unknown error occurred',
    );
  }
}


import 'dart:async';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/graphql/graphql_exceptions.dart';
import '../dto/evolution_detail_dto.dart';
import '../dto/pokemon_detail_dto.dart';
import '../dto/pokemon_form_dto.dart';
import '../dto/pokemon_list_response.dart';
import '../dto/pokemon_summary_dto.dart';
import '../graphql/get_evolution_details_query.dart';
import '../graphql/get_pokemon_detail_query.dart';
import '../graphql/get_pokemon_forms_query.dart';
import '../graphql/get_pokemon_list_query.dart';

/// Fuente de datos remota para obtener información de Pokémon desde la API GraphQL
class PokedexRemoteDatasource {
  const PokedexRemoteDatasource({required GraphQLClient client})
      : _client = client;

  final GraphQLClient _client;

  /// Tamaño de página por defecto para paginación
  static const int defaultPageSize = 50;

  /// Obtiene una página de la lista de Pokémon desde la API
  /// [offset] es el índice inicial (cursor)
  /// [limit] es el tamaño de página
  Future<PokemonListResponse> fetchPokemonList({
    int offset = 0,
    int limit = defaultPageSize,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getPokemonListQuery),
        variables: {'limit': limit, 'offset': offset},
        fetchPolicy: FetchPolicy.cacheFirst,
      ),
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw const PokedexTimeoutException(),
    );

    if (result.hasException) {
      throw _handleException(result.exception!);
    }

    final data = result.data?['pokemon_v2_pokemon'] as List? ?? [];
    final pokemons = data
        .map((json) =>
            PokemonSummaryDto.fromJson((json as Map).cast<String, dynamic>()))
        .toList(growable: false);

    return PokemonListResponse(
      pokemons: pokemons,
      nextOffset: data.length == limit ? offset + limit : null,
      hasMore: data.length == limit,
    );
  }

  /// Obtiene el conteo total de Pokémon
  Future<int> fetchPokemonCount() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getPokemonCountQuery),
        fetchPolicy: FetchPolicy.cacheFirst,
      ),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw const PokedexTimeoutException(),
    );

    if (result.hasException) {
      throw _handleException(result.exception!);
    }

    return result.data?['pokemon_v2_pokemon_aggregate']?['aggregate']?['count'] as int? ?? 0;
  }

  /// Obtiene TODOS los Pokémon sin paginación (para filtrado)
  Future<List<PokemonSummaryDto>> fetchAllPokemon() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getAllPokemonQuery),
        fetchPolicy: FetchPolicy.cacheFirst,
      ),
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw const PokedexTimeoutException(),
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

  /// Obtiene los detalles de evolución para una cadena evolutiva
  Future<List<EvolutionDetailDto>> fetchEvolutionDetails(int chainId) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getEvolutionDetailsQuery),
        variables: {'chainId': chainId},
      ),
    );

    if (result.hasException) {
      throw _handleException(result.exception!);
    }

    final data = result.data?['pokemon_v2_pokemonevolution'] as List? ?? [];
    return data
        .map((json) => EvolutionDetailDto.fromJson((json as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Obtiene las formas alternativas de un Pokémon
  Future<List<PokemonFormDto>> fetchPokemonForms(int speciesId) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getPokemonFormsQuery),
        variables: {'speciesId': speciesId},
      ),
    );

    if (result.hasException) {
      throw _handleException(result.exception!);
    }

    final pokemons = result.data?['pokemon_v2_pokemon'] as List? ?? [];
    final forms = <PokemonFormDto>[];

    for (final pokemon in pokemons) {
      final pokemonJson = (pokemon as Map).cast<String, dynamic>();
      final isPokemonDefault = pokemonJson['is_default'] == true;
      
      // Solo incluir Pokémon no-default (formas alternativas como mega, gmax, etc.)
      if (!isPokemonDefault) {
        final pokemonForms = pokemonJson['pokemon_v2_pokemonforms'] as List? ?? [];
        
        for (final form in pokemonForms) {
          final formJson = (form as Map).cast<String, dynamic>();
          forms.add(PokemonFormDto.fromJson(formJson, pokemonJson));
        }
      }
    }

    return forms;
  }

  /// Obtiene las mega stones para un Pokémon por nombre
  Future<List<Map<String, dynamic>>> fetchMegaStones(String pokemonName) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(getMegaStonesQuery),
        variables: {'pokemonName': '%$pokemonName%'},
      ),
    );

    if (result.hasException) {
      return [];
    }

    final items = result.data?['pokemon_v2_item'] as List? ?? [];
    return items.map((item) {
      final itemJson = (item as Map).cast<String, dynamic>();
      final itemNames = itemJson['pokemon_v2_itemnames'] as List? ?? [];
      String displayName = (itemJson['name'] as String).replaceAll('-', ' ');
      if (itemNames.isNotEmpty) {
        displayName = itemNames.first['name'] as String? ?? displayName;
      }
      return {
        'id': itemJson['id'] as int,
        'name': displayName,
      };
    }).toList();
  }

  /// Convierte excepciones de GraphQL a excepciones personalizadas
  Exception _handleException(OperationException exception) {
    // Verificar errores de link (conexión)
    if (exception.linkException != null) {
      final linkException = exception.linkException;
      
      // Verificar si es timeout
      if (linkException is TimeoutException) {
        return const PokedexTimeoutException();
      }
      
      // Verificar errores de servidor HTTP
      if (linkException is ServerException) {
        final statusCode = linkException.statusCode;
        if (statusCode == 429) {
          return const PokedexRateLimitException();
        }
        if (statusCode != null && statusCode >= 500) {
          return PokedexServerException('Server error (HTTP $statusCode)');
        }
      }
      
      return const PokedexNetworkException();
    }
    
    // Verificar errores GraphQL
    if (exception.graphqlErrors.isNotEmpty) {
      final firstError = exception.graphqlErrors.first;
      final message = firstError.message.toLowerCase();
      
      // Detectar rate limit en mensaje
      if (message.contains('rate limit') || message.contains('too many')) {
        return const PokedexRateLimitException();
      }
      
      // Detectar errores de datos
      if (message.contains('invalid') || message.contains('parse')) {
        return PokedexDataException(firstError.message);
      }
      
      return GraphQLException(firstError.message);
    }
    
    return const GraphQLException('Unknown error occurred');
  }
}

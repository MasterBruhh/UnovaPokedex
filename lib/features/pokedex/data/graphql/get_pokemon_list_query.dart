/// Consulta GraphQL para obtener la lista de Pokémon con paginación
const String getPokemonListQuery = r'''
  query PokemonList($limit: Int!, $offset: Int!) {
    pokemon_v2_pokemon(
      where: {id: {_lte: 1025}}, 
      order_by: {id: asc},
      limit: $limit,
      offset: $offset
    ) {
      id
      name
      pokemon_v2_pokemontypes {
        pokemon_v2_type {
          name
        }
      }
    }
  }
''';

/// Consulta para obtener el total de Pokémon
const String getPokemonCountQuery = r'''
  query PokemonCount {
    pokemon_v2_pokemon_aggregate(where: {id: {_lte: 1025}}) {
      aggregate {
        count
      }
    }
  }
''';

/// Consulta GraphQL para buscar Pokémon por nombre
const String searchPokemonByNameQuery = r'''
  query SearchPokemonByName($searchText: String!) {
    pokemon_v2_pokemon(
      where: {
        id: {_lte: 1025},
        name: {_ilike: $searchText}
      }, 
      order_by: {id: asc}
    ) {
      id
      name
      pokemon_v2_pokemontypes {
        pokemon_v2_type {
          name
        }
      }
    }
  }
''';

/// Consulta GraphQL para filtrar Pokémon por tipo(s)
const String filterPokemonByTypeQuery = r'''
  query FilterPokemonByType($types: [String!]!) {
    pokemon_v2_pokemon(
      where: {
        id: {_lte: 1025},
        pokemon_v2_pokemontypes: {
          pokemon_v2_type: {name: {_in: $types}}
        }
      }, 
      order_by: {id: asc}
    ) {
      id
      name
      pokemon_v2_pokemontypes {
        pokemon_v2_type {
          name
        }
      }
    }
  }
''';

/// Consulta GraphQL para filtrar Pokémon por rango de ID (región)
const String filterPokemonByIdRangeQuery = r'''
  query FilterPokemonByIdRange($minId: Int!, $maxId: Int!) {
    pokemon_v2_pokemon(
      where: {
        id: {_gte: $minId, _lte: $maxId}
      }, 
      order_by: {id: asc}
    ) {
      id
      name
      pokemon_v2_pokemontypes {
        pokemon_v2_type {
          name
        }
      }
    }
  }
''';

/// Consulta GraphQL con filtros combinados (búsqueda + tipos + regiones)
const String filterPokemonCombinedQuery = r'''
  query FilterPokemonCombined($where: pokemon_v2_pokemon_bool_exp!) {
    pokemon_v2_pokemon(
      where: $where, 
      order_by: {id: asc}
    ) {
      id
      name
      pokemon_v2_pokemontypes {
        pokemon_v2_type {
          name
        }
      }
    }
  }
''';

/// Consulta para obtener TODOS los Pokémon (sin paginación) para filtrado local
const String getAllPokemonQuery = r'''
  query AllPokemon {
    pokemon_v2_pokemon(
      where: {id: {_lte: 1025}}, 
      order_by: {id: asc}
    ) {
      id
      name
      pokemon_v2_pokemontypes {
        pokemon_v2_type {
          name
        }
      }
    }
  }
''';


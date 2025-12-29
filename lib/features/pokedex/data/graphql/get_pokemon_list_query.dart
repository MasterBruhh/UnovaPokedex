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


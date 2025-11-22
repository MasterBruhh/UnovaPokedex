/// Consulta GraphQL para obtener la lista de Pokémon
const String getPokemonListQuery = r'''
  query PokemonList {
    pokemon_v2_pokemon(where: {id: {_lte: 1025}}, order_by: {id: asc}) {
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


/// Query para obtener los detalles de evolución de una especie
const String getEvolutionDetailsQuery = r'''
  query GetEvolutionDetails($chainId: Int!) {
    pokemon_v2_pokemonevolution(
      where: {
        pokemon_v2_pokemonspecy: {
          evolution_chain_id: {_eq: $chainId}
        }
      }
    ) {
      id
      evolved_species_id
      min_level
      min_happiness
      min_beauty
      min_affection
      time_of_day
      needs_overworld_rain
      turn_upside_down
      relative_physical_stats
      gender_id
      
      # Trigger de evolución
      pokemon_v2_evolutiontrigger {
        name
      }
      
      # Item para evolucionar (ej: Piedra Fuego)
      pokemon_v2_item {
        id
        name
        pokemon_v2_itemnames(where: {language_id: {_eq: 7}}) {
          name
        }
      }
      
      # Item que debe sostener
      pokemonV2ItemByHeldItemId {
        id
        name
        pokemon_v2_itemnames(where: {language_id: {_eq: 7}}) {
          name
        }
      }
      
      # Ubicación requerida
      pokemon_v2_location {
        id
        pokemon_v2_locationnames(where: {language_id: {_eq: 7}}) {
          name
        }
      }
      
      # Movimiento requerido
      pokemon_v2_move {
        id
        pokemon_v2_movenames(where: {language_id: {_eq: 7}}) {
          name
        }
      }
      
      # Tipo de movimiento requerido
      pokemon_v2_type {
        name
      }
      
      # Especie para intercambiar
      pokemonV2PokemonspecyByTradeSpeciesId {
        id
        name
      }
    }
  }
''';

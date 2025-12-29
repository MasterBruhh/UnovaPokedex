/// Queries GraphQL para el módulo de Trivia.
/// 
/// Contiene todas las consultas necesarias para obtener
/// datos de Pokémon para el juego de trivia.

/// Query para obtener datos completos de un Pokémon para una pregunta.
/// 
/// Variables:
/// - `id` (Int!): El ID del Pokémon a obtener.
/// 
/// Retorna:
/// - Info básica del Pokémon (id, name)
/// - Sprites del Pokémon
/// - Texto flavor de la especie (descripción) en Español (7) o Inglés (9)
const String getPokemonQuestionDataQuery = r'''
  query GetPokemonQuestionData($id: Int!) {
    pokemon_v2_pokemon(where: {id: {_eq: $id}}) {
      id
      name
      pokemon_v2_pokemonsprites {
        sprites
      }
      pokemon_v2_pokemonspecy {
        pokemon_v2_pokemonspeciesflavortexts(
          where: {language_id: {_in: [7, 9]}}
        ) {
          flavor_text
          language_id
        }
      }
    }
  }
''';

/// Query para obtener múltiples Pokémon como opciones de respuesta.
///
/// Variables:
/// - `ids` ([Int!]!): Array de IDs de Pokémon a obtener.
///
/// Retorna:
/// - Lista de Pokémon con sus nombres e IDs
const String getPokemonOptionsQuery = r'''
  query GetPokemonOptions($ids: [Int!]!) {
    pokemon_v2_pokemon(where: {id: {_in: $ids}}) {
      id
      name
    }
  }
''';

/// Query para obtener un Pokémon aleatorio.
///
/// Variables:
/// - `id` (Int!): El ID del Pokémon a obtener.
///
/// Retorna:
/// - Info básica del Pokémon
const String getRandomPokemonQuery = r'''
  query GetRandomPokemon($id: Int!) {
    pokemon_v2_pokemon(where: {id: {_eq: $id}}) {
      id
      name
    }
  }
''';

/// Query para obtener la descripción de un Pokémon.
///
/// Variables:
/// - `id` (Int!): El ID del Pokémon.
///
/// Retorna:
/// - Texto flavor en Español (7) o Inglés (9)
const String getPokemonDescriptionQuery = r'''
  query GetPokemonDescription($id: Int!) {
    pokemon_v2_pokemonspeciesflavortext(
      where: {
        pokemon_species_id: {_eq: $id}, 
        language_id: {_in: [7, 9]}
      }
    ) {
      flavor_text
      language_id
    }
  }
''';
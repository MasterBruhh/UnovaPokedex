/// Query para obtener las formas alternativas de un Pokémon
const String getPokemonFormsQuery = r'''
  query GetPokemonForms($speciesId: Int!) {
    # Obtener todas las variedades de la especie
    pokemon_v2_pokemon(
      where: {pokemon_species_id: {_eq: $speciesId}}
      order_by: {id: asc}
    ) {
      id
      name
      is_default
      height
      weight
      
      pokemon_v2_pokemonforms {
        id
        name
        form_name
        is_default
        is_battle_only
        is_mega
        form_order
        
        pokemon_v2_pokemonformnames(where: {language_id: {_eq: 7}}) {
          name
          pokemon_name
        }
        
        pokemon_v2_pokemonformtypes {
          slot
          pokemon_v2_type {
            name
          }
        }
      }
      
      pokemon_v2_pokemontypes {
        slot
        pokemon_v2_type {
          name
        }
      }
      
      pokemon_v2_pokemonabilities(where: {is_hidden: {_eq: false}}, limit: 1) {
        pokemon_v2_ability {
          name
          pokemon_v2_abilitynames(where: {language_id: {_eq: 7}}) {
            name
          }
        }
      }
    }
    
    # Obtener mega stones relacionadas con la especie
    pokemon_v2_pokemonspecies_by_pk(id: $speciesId) {
      name
    }
  }
''';

/// Query para obtener mega stones por nombre de pokemon
const String getMegaStonesQuery = r'''
  query GetMegaStones($pokemonName: String!) {
    pokemon_v2_item(
      where: {
        name: {_ilike: $pokemonName},
        item_category_id: {_eq: 44}
      }
    ) {
      id
      name
      pokemon_v2_itemnames(where: {language_id: {_eq: 7}}) {
        name
      }
    }
  }
''';

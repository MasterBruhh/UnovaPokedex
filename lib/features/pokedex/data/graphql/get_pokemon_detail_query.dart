const String getPokemonDetailQuery = r'''
  query PokemonDetails($where: pokemon_v2_pokemon_bool_exp!) {
    pokemon_v2_pokemon(where: $where, limit: 1) {
      id
      name
      height
      weight
      pokemon_v2_pokemontypes {
        pokemon_v2_type { name }
      }
      pokemon_v2_pokemonabilities {
        is_hidden
        pokemon_v2_ability { name }
      }
      pokemon_v2_pokemonstats {
        base_stat
        pokemon_v2_stat { name }
      }
      pokemon_v2_pokemonspecy {
        id
        evolution_chain_id
        pokemon_v2_pokemonspeciesflavortexts(
          where: {language_id: {_eq: 7}}
          order_by: {version_id: desc}
          limit: 1
        ) { flavor_text }
        pokemon_v2_evolutionchain {
          pokemon_v2_pokemonspecies(order_by: {order: asc}) {
            id
            name
            evolves_from_species_id
            pokemon_v2_pokemons {
              id
              name
            }
          }
        }
      }
      levelUpMoves: pokemon_v2_pokemonmoves(
        where: {pokemon_v2_movelearnmethod: {name: {_eq: "level-up"}}}
        order_by: [{level: asc}, {move_id: asc}]
      ) {
        move_id
        level
        pokemon_v2_move { name }
      }
      tmMoves: pokemon_v2_pokemonmoves(
        where: {pokemon_v2_movelearnmethod: {name: {_eq: "machine"}}}
        order_by: {move_id: asc}
      ) {
        move_id
        pokemon_v2_move { name }
      }
      tutorMoves: pokemon_v2_pokemonmoves(
        where: {pokemon_v2_movelearnmethod: {name: {_eq: "tutor"}}}
        order_by: {move_id: asc}
      ) {
        move_id
        pokemon_v2_move { name }
      }
      eggMoves: pokemon_v2_pokemonmoves(
        where: {pokemon_v2_movelearnmethod: {name: {_eq: "egg"}}}
        order_by: {move_id: asc}
      ) {
        move_id
        pokemon_v2_move { name }
      }
    }
  }
''';

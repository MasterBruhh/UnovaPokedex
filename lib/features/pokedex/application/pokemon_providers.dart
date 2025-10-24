import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../infrastructure/pokeapi_client.dart';

/// FutureProvider que trae el Pokémon con el nombre que se desea para validar conectividad a PokeAPI.
final dittoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return PokeApiClient.fetchPokemonBasic('riolu');
});

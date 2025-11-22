import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pokemon_detail.dart';
import 'pokedex_providers.dart';

/// Provider family para detalle de Pokémon por nombre
final pokemonDetailProvider =
    FutureProvider.family<PokemonDetail, String>((ref, pokemonName) async {
  final getPokemonDetail = ref.watch(getPokemonDetailUseCaseProvider);
  return await getPokemonDetail(name: pokemonName);
});

/// Provider family para detalle de Pokémon por ID
final pokemonDetailByIdProvider =
    FutureProvider.family<PokemonDetail, int>((ref, pokemonId) async {
  final getPokemonDetail = ref.watch(getPokemonDetailUseCaseProvider);
  return await getPokemonDetail(id: pokemonId);
});

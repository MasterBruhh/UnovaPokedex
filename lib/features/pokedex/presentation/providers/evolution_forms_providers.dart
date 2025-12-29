import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/evolution_detail.dart';
import '../../domain/entities/pokemon_form.dart';
import 'pokedex_providers.dart';

/// Provider para obtener los detalles de evolución de una cadena
final evolutionDetailsProvider = FutureProvider.family<List<EvolutionDetail>, int>((ref, chainId) async {
  final repository = ref.watch(pokedexRepositoryProvider);
  return repository.getEvolutionDetails(chainId);
});

/// Provider para obtener las formas alternativas de un Pokémon
final pokemonFormsProvider = FutureProvider.family<List<PokemonForm>, int>((ref, speciesId) async {
  final repository = ref.watch(pokedexRepositoryProvider);
  return repository.getPokemonForms(speciesId);
});

/// Provider para obtener las mega stones de un Pokémon
final megaStonesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, pokemonName) async {
  final repository = ref.watch(pokedexRepositoryProvider);
  return repository.getMegaStones(pokemonName);
});

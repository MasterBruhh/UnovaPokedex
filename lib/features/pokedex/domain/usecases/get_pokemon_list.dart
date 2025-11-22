import '../entities/pokemon.dart';
import '../repositories/pokedex_repository.dart';

/// Caso de uso para obtener la lista de Pokémon
class GetPokemonList {
  const GetPokemonList(this._repository);

  final PokedexRepository _repository;

  /// Ejecuta el caso de uso para obtener todos los Pokémon
  Future<List<Pokemon>> call() async {
    return await _repository.getPokemonList();
  }
}


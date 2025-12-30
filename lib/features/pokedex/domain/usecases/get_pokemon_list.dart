import '../entities/pokemon.dart';
import '../entities/pokemon_page.dart';
import '../repositories/pokedex_repository.dart';

/// Caso de uso para obtener la lista de Pokémon con paginación
class GetPokemonList {
  const GetPokemonList(this._repository);

  final PokedexRepository _repository;

  /// Ejecuta el caso de uso para obtener una página de Pokémon
  /// [offset] es el cursor (índice inicial), por defecto 0
  /// [limit] es el tamaño de página, por defecto 50
  Future<PokemonPage> call({int offset = 0, int limit = 50}) async {
    return await _repository.getPokemonPage(offset: offset, limit: limit);
  }
  
  /// Obtiene el conteo total de Pokémon
  Future<int> getCount() async {
    return await _repository.getPokemonCount();
  }

  /// Obtiene TODOS los Pokémon sin paginación (para filtrado)
  Future<List<Pokemon>> getAll() async {
    return await _repository.getAllPokemon();
  }
}


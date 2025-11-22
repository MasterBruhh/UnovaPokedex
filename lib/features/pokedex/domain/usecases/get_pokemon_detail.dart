import '../entities/pokemon_detail.dart';
import '../repositories/pokedex_repository.dart';

/// Caso de uso para obtener información detallada del Pokémon
class GetPokemonDetail {
  const GetPokemonDetail(this._repository);

  final PokedexRepository _repository;

  /// Ejecuta el caso de uso para obtener detalles del Pokémon
  /// Se debe proporcionar [id] o [name]
  Future<PokemonDetail> call({int? id, String? name}) async {
    if (id == null && name == null) {
      throw ArgumentError('Either id or name must be provided');
    }
    return await _repository.getPokemonDetail(id: id, name: name);
  }
}


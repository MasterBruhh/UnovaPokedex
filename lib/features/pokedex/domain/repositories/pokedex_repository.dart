import '../entities/pokemon.dart';
import '../entities/pokemon_detail.dart';

/// Interfaz de repositorio para operaciones de datos de Pokémon
/// Esto define el contrato que la capa de datos debe implementar
abstract class PokedexRepository {
  /// Obtiene la lista de todos los Pokémon
  Future<List<Pokemon>> getPokemonList();

  /// Obtiene información detallada para un Pokémon específico
  /// Se debe proporcionar [id] o [name]
  Future<PokemonDetail> getPokemonDetail({int? id, String? name});
}


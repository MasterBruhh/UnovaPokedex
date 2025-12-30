import '../entities/evolution_detail.dart';
import '../entities/pokemon.dart';
import '../entities/pokemon_detail.dart';
import '../entities/pokemon_form.dart';
import '../entities/pokemon_page.dart';

/// Interfaz de repositorio para operaciones de datos de Pokémon
/// Esto define el contrato que la capa de datos debe implementar
abstract class PokedexRepository {
  /// Obtiene una página de Pokémon con paginación basada en cursor
  /// [offset] es el cursor (índice inicial)
  /// [limit] es el tamaño de página
  Future<PokemonPage> getPokemonPage({int offset = 0, int limit = 50});
  
  /// Obtiene el conteo total de Pokémon
  Future<int> getPokemonCount();

  /// Obtiene TODOS los Pokémon sin paginación (para filtrado)
  Future<List<Pokemon>> getAllPokemon();

  /// Obtiene información detallada para un Pokémon específico
  /// Se debe proporcionar [id] o [name]
  Future<PokemonDetail> getPokemonDetail({int? id, String? name});

  /// Obtiene los detalles de evolución para una cadena evolutiva
  Future<List<EvolutionDetail>> getEvolutionDetails(int chainId);

  /// Obtiene las formas alternativas de un Pokémon
  Future<List<PokemonForm>> getPokemonForms(int speciesId);

  /// Obtiene las mega stones para un Pokémon
  Future<List<Map<String, dynamic>>> getMegaStones(String pokemonName);
}


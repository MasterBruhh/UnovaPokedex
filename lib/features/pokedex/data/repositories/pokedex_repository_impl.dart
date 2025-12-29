import '../../domain/entities/evolution_detail.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/entities/pokemon_detail.dart';
import '../../domain/entities/pokemon_form.dart';
import '../../domain/entities/pokemon_page.dart';
import '../../domain/repositories/pokedex_repository.dart';
import '../datasources/pokedex_remote_datasource.dart';

/// Implementación de PokedexRepository
/// Esto conecta las capas de dominio y datos
class PokedexRepositoryImpl implements PokedexRepository {
  const PokedexRepositoryImpl({
    required PokedexRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  final PokedexRemoteDatasource _remoteDatasource;

  @override
  Future<PokemonPage> getPokemonPage({int offset = 0, int limit = 50}) async {
    final response = await _remoteDatasource.fetchPokemonList(
      offset: offset,
      limit: limit,
    );
    return PokemonPage(
      pokemons: response.pokemons.map((dto) => dto.toDomain()).toList(),
      nextCursor: response.nextOffset,
      hasMore: response.hasMore,
    );
  }

  @override
  Future<int> getPokemonCount() async {
    return await _remoteDatasource.fetchPokemonCount();
  }

  @override
  Future<PokemonDetail> getPokemonDetail({int? id, String? name}) async {
    final dto = await _remoteDatasource.fetchPokemonDetail(id: id, name: name);
    return dto.toDomain();
  }

  @override
  Future<List<EvolutionDetail>> getEvolutionDetails(int chainId) async {
    final dtos = await _remoteDatasource.fetchEvolutionDetails(chainId);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<List<PokemonForm>> getPokemonForms(int speciesId) async {
    final dtos = await _remoteDatasource.fetchPokemonForms(speciesId);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getMegaStones(String pokemonName) async {
    return await _remoteDatasource.fetchMegaStones(pokemonName);
  }
}


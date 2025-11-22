import '../../domain/entities/pokemon.dart';
import '../../domain/entities/pokemon_detail.dart';
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
  Future<List<Pokemon>> getPokemonList() async {
    final dtos = await _remoteDatasource.fetchPokemonList();
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<PokemonDetail> getPokemonDetail({int? id, String? name}) async {
    final dto = await _remoteDatasource.fetchPokemonDetail(id: id, name: name);
    return dto.toDomain();
  }
}


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/graphql/graphql_client_provider.dart';
import '../../data/datasources/pokedex_remote_datasource.dart';
import '../../data/repositories/pokedex_repository_impl.dart';
import '../../domain/repositories/pokedex_repository.dart';
import '../../domain/usecases/get_evolution_chain.dart';
import '../../domain/usecases/get_pokemon_detail.dart';
import '../../domain/usecases/get_pokemon_list.dart';

/// Provider para el valor del cliente GraphQL
final graphqlClientValueProvider = Provider<GraphQLClient>((ref) {
  return ref.watch(graphqlClientProvider).value;
});

/// Provider para la fuente de datos remota
final pokedexRemoteDatasourceProvider = Provider<PokedexRemoteDatasource>((ref) {
  final client = ref.watch(graphqlClientValueProvider);
  return PokedexRemoteDatasource(client: client);
});

/// Provider para el repositorio
final pokedexRepositoryProvider = Provider<PokedexRepository>((ref) {
  final datasource = ref.watch(pokedexRemoteDatasourceProvider);
  return PokedexRepositoryImpl(remoteDatasource: datasource);
});

/// Provider para el caso de uso GetPokemonList
final getPokemonListUseCaseProvider = Provider<GetPokemonList>((ref) {
  final repository = ref.watch(pokedexRepositoryProvider);
  return GetPokemonList(repository);
});

/// Provider para el caso de uso GetPokemonDetail
final getPokemonDetailUseCaseProvider = Provider<GetPokemonDetail>((ref) {
  final repository = ref.watch(pokedexRepositoryProvider);
  return GetPokemonDetail(repository);
});

/// Provider para el caso de uso GetEvolutionChain
final getEvolutionChainUseCaseProvider = Provider<GetEvolutionChain>((ref) {
  return const GetEvolutionChain();
});


import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/graphql/graphql_exceptions.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/entities/pokemon_region.dart';
import '../../domain/entities/pokemon_type.dart';
import 'pokedex_providers.dart';

/// Tamaño de página para la carga de Pokémon
const int _pageSize = 50;

/// Estado para la lista de Pokémon con paginación
class PokemonListState {
  const PokemonListState({
    required this.allPokemon,
    required this.filteredPokemon,
    required this.isLoading,
    required this.isLoadingMore,
    required this.error,
    required this.searchText,
    required this.selectedTypes,
    required this.selectedRegions,
    required this.hasMore,
    required this.nextCursor,
    this.totalCount,
  });

  final List<Pokemon> allPokemon;
  final List<Pokemon> filteredPokemon;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String searchText;
  final Set<PokemonType> selectedTypes;
  final Set<PokemonRegion> selectedRegions;
  final bool hasMore;
  final int? nextCursor;
  final int? totalCount;

  /// Mensaje de error amigable para el usuario
  String? get userFriendlyError {
    if (error == null) return null;
    if (error!.contains('Network error') || error!.contains('PokedexNetworkException')) {
      return 'Sin conexión a internet. Verifica tu red y vuelve a intentar.';
    }
    if (error!.contains('Timeout') || error!.contains('PokedexTimeoutException')) {
      return 'La conexión tardó demasiado. Intenta de nuevo.';
    }
    if (error!.contains('Rate limit') || error!.contains('PokedexRateLimitException')) {
      return 'Demasiadas solicitudes. Espera un momento y vuelve a intentar.';
    }
    if (error!.contains('Server error') || error!.contains('PokedexServerException')) {
      return 'Error del servidor. Intenta más tarde.';
    }
    return 'Error al cargar los Pokémon. Intenta de nuevo.';
  }

  PokemonListState copyWith({
    List<Pokemon>? allPokemon,
    List<Pokemon>? filteredPokemon,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? searchText,
    Set<PokemonType>? selectedTypes,
    Set<PokemonRegion>? selectedRegions,
    bool? hasMore,
    int? nextCursor,
    bool clearNextCursor = false,
    int? totalCount,
  }) {
    return PokemonListState(
      allPokemon: allPokemon ?? this.allPokemon,
      filteredPokemon: filteredPokemon ?? this.filteredPokemon,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      searchText: searchText ?? this.searchText,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      selectedRegions: selectedRegions ?? this.selectedRegions,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

/// Notificador para el estado de la lista de Pokémon con paginación
class PokemonListNotifier extends Notifier<PokemonListState> {
  @override
  PokemonListState build() {
    // Inicializar y cargar primera página asíncronamente
    Future.microtask(() => _loadInitialPage());
    
    return const PokemonListState(
      allPokemon: [],
      filteredPokemon: [],
      isLoading: true,
      isLoadingMore: false,
      error: null,
      searchText: '',
      selectedTypes: {},
      selectedRegions: {},
      hasMore: true,
      nextCursor: null,
      totalCount: null,
    );
  }

  /// Carga la primera página de Pokémon
  Future<void> _loadInitialPage() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final getPokemonList = ref.read(getPokemonListUseCaseProvider);
      
      // Obtener conteo total primero
      final totalCount = await getPokemonList.getCount();
      
      // Obtener primera página
      final page = await getPokemonList(offset: 0, limit: _pageSize);
      
      state = state.copyWith(
        allPokemon: page.pokemons,
        filteredPokemon: page.pokemons,
        isLoading: false,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
        totalCount: totalCount,
      );
    } on GraphQLException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Carga más Pokémon (siguiente página)
  Future<void> loadMore() async {
    // No cargar si ya está cargando o no hay más páginas
    if (state.isLoadingMore || state.isLoading || !state.hasMore) return;
    
    final cursor = state.nextCursor;
    if (cursor == null) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final getPokemonList = ref.read(getPokemonListUseCaseProvider);
      final page = await getPokemonList(offset: cursor, limit: _pageSize);
      
      final newAllPokemon = [...state.allPokemon, ...page.pokemons];
      
      state = state.copyWith(
        allPokemon: newAllPokemon,
        isLoadingMore: false,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
      );
      
      // Re-aplicar filtros a la nueva lista completa
      _applyFilters();
    } on GraphQLException catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Actualiza el texto de búsqueda y aplica los filtros
  void setSearchText(String text) {
    state = state.copyWith(searchText: text);
    _applyFilters();
  }

  /// Alterna un filtro de tipo
  void toggleTypeFilter(PokemonType type) {
    final newTypes = Set<PokemonType>.from(state.selectedTypes);
    if (newTypes.contains(type)) {
      newTypes.remove(type);
    } else {
      newTypes.add(type);
    }
    state = state.copyWith(selectedTypes: newTypes);
    _applyFilters();
  }

  /// Alterna un filtro de región
  void toggleRegionFilter(PokemonRegion region) {
    final newRegions = Set<PokemonRegion>.from(state.selectedRegions);
    if (newRegions.contains(region)) {
      newRegions.remove(region);
    } else {
      newRegions.add(region);
    }
    state = state.copyWith(selectedRegions: newRegions);
    _applyFilters();
  }

  /// Limpia todos los filtros
  void clearFilters() {
    state = state.copyWith(
      searchText: '',
      selectedTypes: {},
      selectedRegions: {},
      filteredPokemon: state.allPokemon,
    );
  }

  /// Aplica todos los filtros a la lista de Pokémon
  void _applyFilters() {
    var filtered = List<Pokemon>.from(state.allPokemon);

    // Aplicar filtro de búsqueda
    if (state.searchText.isNotEmpty) {
      filtered = filtered
          .where((pokemon) =>
              pokemon.name.toLowerCase().contains(state.searchText.toLowerCase()))
          .toList();
    }

    // Aplicar filtros de tipo
    if (state.selectedTypes.isNotEmpty) {
      if (state.selectedTypes.length > 2) {
        // Ningún Pokémon puede tener más de 2 tipos
        filtered = [];
      } else {
        filtered = filtered
            .where((pokemon) =>
                state.selectedTypes.every(pokemon.types.contains))
            .toList();
      }
    }

    // Aplicar filtros de región
    if (state.selectedRegions.isNotEmpty) {
      filtered = filtered
          .where((pokemon) =>
              state.selectedRegions.contains(PokemonRegion.fromPokemonId(pokemon.id)))
          .toList();
    }

    state = state.copyWith(filteredPokemon: filtered);
  }

  /// Reintenta cargar la lista de Pokémon
  Future<void> retry() async {
    await _loadInitialPage();
  }
}

/// Provider para el estado de la lista de Pokémon
final pokemonListProvider =
    NotifierProvider<PokemonListNotifier, PokemonListState>(
  PokemonListNotifier.new,
);

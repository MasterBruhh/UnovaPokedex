import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/graphql/graphql_exceptions.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/entities/pokemon_region.dart';
import '../../domain/entities/pokemon_type.dart';
import 'pokedex_providers.dart';

/// Tamaño de página para la carga de Pokémon (modo sin filtros)
const int _pageSize = 50;

/// Opciones de ordenación
enum SortOption {
  numberAsc,   // Por número ascendente (por defecto)
  numberDesc,  // Por número descendente
  nameAsc,     // Por nombre A-Z
  nameDesc,    // Por nombre Z-A
}

/// Estado para la lista de Pokémon con paginación y filtros
class PokemonListState {
  const PokemonListState({
    required this.allPokemon,
    required this.filteredPokemon,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isLoadingAll,
    required this.error,
    required this.searchText,
    required this.selectedTypes,
    required this.selectedRegions,
    required this.sortOption,
    required this.hasMore,
    required this.nextCursor,
    required this.hasFiltersActive,
    required this.allPokemonLoaded,
    this.totalCount,
  });

  final List<Pokemon> allPokemon;
  final List<Pokemon> filteredPokemon;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isLoadingAll; // Cargando todos los Pokémon para filtrado
  final String? error;
  final String searchText;
  final Set<PokemonType> selectedTypes;
  final Set<PokemonRegion> selectedRegions;
  final SortOption sortOption;
  final bool hasMore;
  final int? nextCursor;
  final int? totalCount;
  final bool hasFiltersActive;
  final bool allPokemonLoaded; // Ya se cargaron todos los Pokémon

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
    bool? isLoadingAll,
    String? error,
    String? searchText,
    Set<PokemonType>? selectedTypes,
    Set<PokemonRegion>? selectedRegions,
    SortOption? sortOption,
    bool? hasMore,
    int? nextCursor,
    bool clearNextCursor = false,
    int? totalCount,
    bool? hasFiltersActive,
    bool? allPokemonLoaded,
  }) {
    return PokemonListState(
      allPokemon: allPokemon ?? this.allPokemon,
      filteredPokemon: filteredPokemon ?? this.filteredPokemon,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoadingAll: isLoadingAll ?? this.isLoadingAll,
      error: error,
      searchText: searchText ?? this.searchText,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      selectedRegions: selectedRegions ?? this.selectedRegions,
      sortOption: sortOption ?? this.sortOption,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      totalCount: totalCount ?? this.totalCount,
      hasFiltersActive: hasFiltersActive ?? this.hasFiltersActive,
      allPokemonLoaded: allPokemonLoaded ?? this.allPokemonLoaded,
    );
  }
}

/// Notificador para el estado de la lista de Pokémon con paginación y filtros
class PokemonListNotifier extends Notifier<PokemonListState> {
  // Caché de todos los Pokémon para no recargar
  List<Pokemon>? _allPokemonCache;
  
  @override
  PokemonListState build() {
    // Inicializar y cargar primera página asíncronamente
    Future.microtask(() => _initialize());
    
    return const PokemonListState(
      allPokemon: [],
      filteredPokemon: [],
      isLoading: true,
      isLoadingMore: false,
      isLoadingAll: false,
      error: null,
      searchText: '',
      selectedTypes: {},
      selectedRegions: {},
      sortOption: SortOption.numberAsc,
      hasMore: true,
      nextCursor: null,
      totalCount: null,
      hasFiltersActive: false,
      allPokemonLoaded: false,
    );
  }

  /// Inicializa el provider cargando filtros guardados y datos iniciales
  Future<void> _initialize() async {
    // Cargar filtros guardados
    await _loadSavedFilters();
    
    // Si hay filtros activos, cargar todos los Pokémon
    if (_hasActiveFilters()) {
      await _loadAllPokemon();
    } else {
      await _loadInitialPage();
    }
  }

  /// Verifica si hay filtros activos
  bool _hasActiveFilters() {
    return state.searchText.isNotEmpty || 
           state.selectedTypes.isNotEmpty || 
           state.selectedRegions.isNotEmpty;
  }

  /// Carga filtros guardados desde SharedPreferences
  Future<void> _loadSavedFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final searchText = prefs.getString('filter_searchText') ?? '';
      final typeNames = prefs.getStringList('filter_types') ?? [];
      final regionNames = prefs.getStringList('filter_regions') ?? [];
      final sortIndex = prefs.getInt('filter_sortOption') ?? 0;
      
      final selectedTypes = typeNames
          .map((name) {
            try {
              return PokemonType.values.firstWhere((t) => t.name == name);
            } catch (_) {
              return null;
            }
          })
          .whereType<PokemonType>()
          .toSet();
      
      final selectedRegions = regionNames
          .map((name) {
            try {
              return PokemonRegion.values.firstWhere((r) => r.name == name);
            } catch (_) {
              return null;
            }
          })
          .whereType<PokemonRegion>()
          .toSet();
      
      final sortOption = SortOption.values[sortIndex.clamp(0, SortOption.values.length - 1)];
      
      state = state.copyWith(
        searchText: searchText,
        selectedTypes: selectedTypes,
        selectedRegions: selectedRegions,
        sortOption: sortOption,
        hasFiltersActive: searchText.isNotEmpty || selectedTypes.isNotEmpty || selectedRegions.isNotEmpty,
      );
    } catch (e) {
      // Ignorar errores de carga de preferencias
    }
  }

  /// Guarda filtros en SharedPreferences
  Future<void> _saveFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('filter_searchText', state.searchText);
      await prefs.setStringList(
        'filter_types', 
        state.selectedTypes.map((t) => t.name).toList(),
      );
      await prefs.setStringList(
        'filter_regions', 
        state.selectedRegions.map((r) => r.name).toList(),
      );
      await prefs.setInt('filter_sortOption', state.sortOption.index);
    } catch (e) {
      // Ignorar errores de guardado
    }
  }

  /// Carga la primera página de Pokémon (modo sin filtros)
  Future<void> _loadInitialPage() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final getPokemonList = ref.read(getPokemonListUseCaseProvider);
      
      // Obtener conteo total primero
      final totalCount = await getPokemonList.getCount();
      
      // Obtener primera página
      final page = await getPokemonList(offset: 0, limit: _pageSize);
      
      final sortedPokemon = _sortPokemon(page.pokemons);
      
      state = state.copyWith(
        allPokemon: page.pokemons,
        filteredPokemon: sortedPokemon,
        isLoading: false,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
        totalCount: totalCount,
        hasFiltersActive: false,
        allPokemonLoaded: false,
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

  /// Carga TODOS los Pokémon (para filtrado)
  Future<void> _loadAllPokemon() async {
    // Si ya tenemos caché, usarlo
    if (_allPokemonCache != null) {
      state = state.copyWith(
        allPokemon: _allPokemonCache!,
        isLoading: false,
        isLoadingAll: false,
        hasMore: false,
        allPokemonLoaded: true,
        totalCount: _allPokemonCache!.length,
      );
      _applyFilters();
      return;
    }

    state = state.copyWith(
      isLoading: state.allPokemon.isEmpty,
      isLoadingAll: true,
      error: null,
    );

    try {
      final getPokemonList = ref.read(getPokemonListUseCaseProvider);
      final allPokemon = await getPokemonList.getAll();
      
      _allPokemonCache = allPokemon;
      
      state = state.copyWith(
        allPokemon: allPokemon,
        isLoading: false,
        isLoadingAll: false,
        hasMore: false,
        allPokemonLoaded: true,
        totalCount: allPokemon.length,
      );
      
      _applyFilters();
    } on GraphQLException catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingAll: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingAll: false,
        error: e.toString(),
      );
    }
  }

  /// Carga más Pokémon (siguiente página) - solo cuando no hay filtros
  Future<void> loadMore() async {
    // No cargar más si hay filtros activos (ya se cargaron todos)
    if (state.hasFiltersActive || state.allPokemonLoaded) return;
    
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
        filteredPokemon: _sortPokemon(newAllPokemon),
        isLoadingMore: false,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
      );
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
    _onFilterChanged();
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
    _onFilterChanged();
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
    _onFilterChanged();
  }

  /// Cambia la opción de ordenación
  void setSortOption(SortOption option) {
    state = state.copyWith(sortOption: option);
    _saveFilters();
    _applyFilters();
  }

  /// Limpia todos los filtros
  void clearFilters() {
    state = state.copyWith(
      searchText: '',
      selectedTypes: {},
      selectedRegions: {},
      hasFiltersActive: false,
    );
    _saveFilters();
    
    // Volver a modo paginado si estábamos en modo filtrado
    if (state.allPokemonLoaded) {
      _loadInitialPage();
    } else {
      _applyFilters();
    }
  }

  /// Llamado cuando cambia un filtro
  Future<void> _onFilterChanged() async {
    final hasFilters = _hasActiveFilters();
    state = state.copyWith(hasFiltersActive: hasFilters);
    
    // Guardar filtros
    await _saveFilters();
    
    // Si hay filtros activos y no hemos cargado todos los Pokémon, cargarlos
    if (hasFilters && !state.allPokemonLoaded) {
      await _loadAllPokemon();
    } else {
      _applyFilters();
    }
  }

  /// Aplica todos los filtros a la lista de Pokémon
  void _applyFilters() {
    var filtered = List<Pokemon>.from(state.allPokemon);

    // Aplicar filtro de búsqueda por nombre o número
    if (state.searchText.isNotEmpty) {
      final searchLower = state.searchText.toLowerCase();
      filtered = filtered.where((pokemon) {
        // Buscar por nombre
        if (pokemon.name.toLowerCase().contains(searchLower)) {
          return true;
        }
        // Buscar por número (con o sin #)
        final searchNum = searchLower.replaceAll('#', '');
        if (int.tryParse(searchNum) != null) {
          return pokemon.id.toString().contains(searchNum) ||
                 pokemon.id.toString().padLeft(3, '0').contains(searchNum);
        }
        return false;
      }).toList();
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

    // Aplicar ordenación
    filtered = _sortPokemon(filtered);

    state = state.copyWith(filteredPokemon: filtered);
  }

  /// Ordena la lista de Pokémon según la opción seleccionada
  List<Pokemon> _sortPokemon(List<Pokemon> pokemon) {
    final sorted = List<Pokemon>.from(pokemon);
    
    switch (state.sortOption) {
      case SortOption.numberAsc:
        sorted.sort((a, b) => a.id.compareTo(b.id));
        break;
      case SortOption.numberDesc:
        sorted.sort((a, b) => b.id.compareTo(a.id));
        break;
      case SortOption.nameAsc:
        sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.nameDesc:
        sorted.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
    }
    
    return sorted;
  }

  /// Reintenta cargar la lista de Pokémon
  Future<void> retry() async {
    if (state.hasFiltersActive) {
      await _loadAllPokemon();
    } else {
      await _loadInitialPage();
    }
  }
}

/// Provider para el estado de la lista de Pokémon
final pokemonListProvider =
    NotifierProvider<PokemonListNotifier, PokemonListState>(
  PokemonListNotifier.new,
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/entities/pokemon_region.dart';
import '../../domain/entities/pokemon_type.dart';
import 'pokedex_providers.dart';

/// Estado para la lista de Pokémon
class PokemonListState {
  const PokemonListState({
    required this.allPokemon,
    required this.filteredPokemon,
    required this.isLoading,
    required this.error,
    required this.searchText,
    required this.selectedTypes,
    required this.selectedRegions,
  });

  final List<Pokemon> allPokemon;
  final List<Pokemon> filteredPokemon;
  final bool isLoading;
  final String? error;
  final String searchText;
  final Set<PokemonType> selectedTypes;
  final Set<PokemonRegion> selectedRegions;

  PokemonListState copyWith({
    List<Pokemon>? allPokemon,
    List<Pokemon>? filteredPokemon,
    bool? isLoading,
    String? error,
    String? searchText,
    Set<PokemonType>? selectedTypes,
    Set<PokemonRegion>? selectedRegions,
  }) {
    return PokemonListState(
      allPokemon: allPokemon ?? this.allPokemon,
      filteredPokemon: filteredPokemon ?? this.filteredPokemon,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchText: searchText ?? this.searchText,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      selectedRegions: selectedRegions ?? this.selectedRegions,
    );
  }
}

/// Notificador para el estado de la lista de Pokémon
class PokemonListNotifier extends Notifier<PokemonListState> {
  @override
  PokemonListState build() {
    // Inicializar y cargar Pokémon asíncronamente
    Future.microtask(() => _loadPokemon());
    
    return const PokemonListState(
      allPokemon: [],
      filteredPokemon: [],
      isLoading: true,
      error: null,
      searchText: '',
      selectedTypes: {},
      selectedRegions: {},
    );
  }

  /// Carga la lista de Pokémon
  Future<void> _loadPokemon() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final getPokemonList = ref.read(getPokemonListUseCaseProvider);
      final pokemon = await getPokemonList();
      state = state.copyWith(
        allPokemon: pokemon,
        filteredPokemon: pokemon,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
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
    await _loadPokemon();
  }
}

/// Provider para el estado de la lista de Pokémon
final pokemonListProvider =
    NotifierProvider<PokemonListNotifier, PokemonListState>(
  PokemonListNotifier.new,
);

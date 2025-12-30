import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/frosted_icon_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/unova_grid_background.dart';
import '../../domain/entities/pokemon_region.dart';
import '../providers/pokemon_list_provider.dart';
import '../widgets/pokemon_list/counter_pill.dart';
import '../widgets/pokemon_list/filter_bottom_sheet.dart';
import '../widgets/pokemon_list/pokedex_book_spine.dart';
import '../widgets/pokemon_list/pokedex_list_card.dart';

/// Página que muestra la lista de Pokémon como lomos de libros
class PokedexListPage extends ConsumerStatefulWidget {
  const PokedexListPage({super.key});

  @override
  ConsumerState<PokedexListPage> createState() => _PokedexListPageState();
}

class _PokedexListPageState extends ConsumerState<PokedexListPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  double _rotationAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      final newOffset = _scrollController.offset;
      final delta = newOffset - _scrollOffset;
      _rotationAngle += delta * 0.01; // Controla la velocidad de rotación
      _scrollOffset = newOffset;
    });
    
    // Cargar más cuando estamos cerca del final
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(pokemonListProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(pokemonListProvider);
          final notifier = ref.read(pokemonListProvider.notifier);
          
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) => FilterBottomSheet(
              searchText: state.searchText,
              selectedTypes: state.selectedTypes,
              selectedRegions: state.selectedRegions,
              sortOption: state.sortOption,
              isLoadingAll: state.isLoadingAll,
              onSearchChanged: (text) => notifier.setSearchText(text),
              onTypeToggled: (type) => notifier.toggleTypeFilter(type),
              onRegionToggled: (region) => notifier.toggleRegionFilter(region),
              onSortChanged: (option) => notifier.setSortOption(option),
              onClearFilters: () => notifier.clearFilters(),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pokemonListProvider);
    final topPadding = MediaQuery.of(context).padding.top + 68;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: const Color(0xFF1A6B5C),
      body: Stack(
        children: [
          const Positioned.fill(child: UnovaGridBackground()),
          Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: _buildBody(context, state, isPortrait),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  FrostedIconButton(
                    icon: Icons.arrow_back,
                    onPressed: () => context.pop(),
                    tooltip: 'Volver',
                  ),
                  const SizedBox(width: 8),
                  CounterPill(count: state.filteredPokemon.length),
                  // Indicador de filtros activos
                  if (state.hasFiltersActive)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.filter_alt, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Filtrado',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  // Indicador de carga de todos los Pokémon
                  if (state.isLoadingAll)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 24,
                      height: 24,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  // Botón de filtros con badge si hay filtros activos
                  Stack(
                    children: [
                      FrostedIconButton(
                        icon: Icons.filter_list_rounded,
                        onPressed: () => _openFilterSheet(context),
                        tooltip: 'Filtros',
                      ),
                      if (state.hasFiltersActive)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    PokemonListState state,
    bool isPortrait,
  ) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    if (state.error != null) {
      return _buildError(context, state.error!);
    }

    if (state.filteredPokemon.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron Pokémon con los filtros seleccionados',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
    }

    return isPortrait
        ? Stack(
            children: [
              ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                itemCount: state.filteredPokemon.length + (state.isLoadingMore || state.hasMore ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  // Mostrar indicador de carga al final
                  if (index >= state.filteredPokemon.length) {
                    return _buildLoadMoreIndicator(state);
                  }
                  
                  final pokemon = state.filteredPokemon[index];
                  final region = PokemonRegion.fromPokemonId(pokemon.id);

                  return _buildScaledCard(
                    index: index,
                    pokemonId: pokemon.id,
                    pokemonName: pokemon.name,
                    pokemonTypes: pokemon.types,
                    region: region,
                  );
                },
              ),
              _buildPokeballIndicator(),
              // Progress indicator
              if (state.totalCount != null)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: _buildProgressBar(state),
                ),
            ],
          )
        : Stack(
            children: [
              ListView.builder(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                itemCount: state.filteredPokemon.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Mostrar indicador de carga al final
                  if (index >= state.filteredPokemon.length) {
                    return _buildLoadMoreIndicatorHorizontal();
                  }
                  
                  final pokemon = state.filteredPokemon[index];
                  final region = PokemonRegion.fromPokemonId(pokemon.id);

                  return _buildScaledBookSpine(
                    index: index,
                    pokemonId: pokemon.id,
                    pokemonName: pokemon.name,
                    pokemonTypes: pokemon.types,
                    region: region,
                  );
                },
              ),
              _buildPokeballIndicatorHorizontal(),
            ],
          );
  }

  /// Indicador de carga al final de la lista (portrait)
  Widget _buildLoadMoreIndicator(PokemonListState state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.white70,
            ),
          ),
        ),
      );
    }
    
    // Si hay más pero no está cargando, mostrar hint de scroll
    if (state.hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Desplaza para cargar más...',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  /// Indicador de carga al final de la lista (landscape)
  Widget _buildLoadMoreIndicatorHorizontal() {
    return Container(
      width: 60,
      margin: const EdgeInsets.only(left: 8),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        strokeWidth: 3,
        color: Colors.white70,
      ),
    );
  }

  /// Barra de progreso mostrando cuántos Pokémon se han cargado
  Widget _buildProgressBar(PokemonListState state) {
    final loaded = state.allPokemon.length;
    final total = state.totalCount ?? 1025;
    final progress = (loaded / total).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$loaded / $total',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildScaledBookSpine({
    required int index,
    required int pokemonId,
    required String pokemonName,
    required List pokemonTypes,
    required PokemonRegion region,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) {
            double scale = 1.0;
            double translateY = 0.0;
            double opacity = 0.5;
            
            if (_scrollController.hasClients) {
              final itemWidth = 100.0 + 8.0; // book width + margin
              final viewportWidth = MediaQuery.of(context).size.width;
              final centerX = viewportWidth / 2;
              
              final itemOffset = (index * itemWidth) - _scrollController.offset;
              final itemCenter = itemOffset + 100.0 / 2;
              
              final distanceFromCenter = (itemCenter - centerX).abs();
              final maxDistance = viewportWidth / 2;
              
              if (distanceFromCenter < maxDistance) {
                scale = 1.0 + (0.15 * (1 - (distanceFromCenter / maxDistance)));
                translateY = -20.0 * (1 - (distanceFromCenter / maxDistance));
                opacity = 0.5 + (0.5 * (1 - (distanceFromCenter / maxDistance)));
              }
            }
            
            return Transform.translate(
              offset: Offset(0, translateY),
              child: Transform.scale(
                scale: scale,
                child: PokedexBookSpine(
                  id: pokemonId,
                  name: pokemonName,
                  types: pokemonTypes.cast(),
                  region: region,
                  opacity: opacity,
                  onTap: () => context.push(
                    '/pokedex/${Uri.encodeComponent(pokemonName)}',
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPokeballIndicatorHorizontal() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: Transform.rotate(
            angle: _rotationAngle,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 3,
                    color: Colors.black,
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScaledCard({
    required int index,
    required int pokemonId,
    required String pokemonName,
    required List pokemonTypes,
    required PokemonRegion region,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) {
            double scale = 1.0;
            double translateX = 0.0;
            double opacity = 0.5;
            
            if (_scrollController.hasClients) {
              final itemHeight = 68.0 + 14.0; // card height + separator
              final viewportHeight = MediaQuery.of(context).size.height;
              final topPadding = MediaQuery.of(context).padding.top + 68;
              final centerY = (viewportHeight - topPadding) / 2;
              
              final itemOffset = (index * itemHeight) - _scrollController.offset;
              final itemCenter = itemOffset + 68.0 / 2;
              
              final distanceFromCenter = (itemCenter - centerY).abs();
              final maxDistance = viewportHeight / 2;
              
              if (distanceFromCenter < maxDistance) {
                scale = 1.0 + (0.03 * (1 - (distanceFromCenter / maxDistance)));
                translateX = 29.0 * (0.3 - (distanceFromCenter / maxDistance));
                opacity = 0.5 + (0.5 * (1 - (distanceFromCenter / maxDistance)));
              }
            }
            
            return Transform.translate(
              offset: Offset(translateX, 0),
              child: Transform.scale(
                scale: scale,
                child: PokedexListCard(
                  id: pokemonId,
                  name: pokemonName,
                  types: pokemonTypes.cast(),
                  region: region,
                  opacity: opacity,
                  onTap: () => context.push(
                    '/pokedex/${Uri.encodeComponent(pokemonName)}',
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPokeballIndicator() {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Center(
          child: Transform.rotate(
            angle: _rotationAngle,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 3,
                    color: Colors.black,
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    final state = ref.read(pokemonListProvider);
    final friendlyMessage = state.userFriendlyError ?? 
        'No se pudo cargar la Pokédex. Revisa tu conexión a internet y vuelve a intentar.';
    
    // Determinar icono según tipo de error
    IconData errorIcon = Icons.error_outline;
    if (error.contains('Network') || error.contains('connection')) {
      errorIcon = Icons.wifi_off;
    } else if (error.contains('Timeout')) {
      errorIcon = Icons.access_time;
    } else if (error.contains('Rate limit')) {
      errorIcon = Icons.speed;
    } else if (error.contains('Server')) {
      errorIcon = Icons.cloud_off;
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              errorIcon,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            Text(
              friendlyMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref.read(pokemonListProvider.notifier).retry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A6B5C),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

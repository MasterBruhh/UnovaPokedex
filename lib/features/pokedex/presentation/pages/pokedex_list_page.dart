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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openFilterSheet(BuildContext context) {
    final state = ref.read(pokemonListProvider);
    final notifier = ref.read(pokemonListProvider.notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => FilterBottomSheet(
        searchText: state.searchText,
        selectedTypes: state.selectedTypes,
        selectedRegions: state.selectedRegions,
        onSearchChanged: (text) => notifier.setSearchText(text),
        onTypeToggled: (type) => notifier.toggleTypeFilter(type),
        onRegionToggled: (region) => notifier.toggleRegionFilter(region),
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
                  const Spacer(),
                  FrostedIconButton(
                    icon: Icons.filter_list_rounded,
                    onPressed: () => _openFilterSheet(context),
                    tooltip: 'Filtros',
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
                itemCount: state.filteredPokemon.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
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
            ],
          )
        : Stack(
            children: [
              ListView.builder(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                itemCount: state.filteredPokemon.length,
                itemBuilder: (context, index) {
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No se pudo cargar la Pokédex. Revisa tu conexión a internet y vuelve a intentar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => ref.read(pokemonListProvider.notifier).retry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

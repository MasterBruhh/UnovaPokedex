import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/frosted_icon_button.dart';
import '../../../../core/widgets/unova_grid_background.dart';
import '../../../pokedex/domain/entities/pokemon_region.dart';
import '../../../pokedex/presentation/widgets/pokemon_list/pokedex_book_spine.dart';
import '../../../pokedex/presentation/widgets/pokemon_list/pokedex_list_card.dart';
import '../providers/favorites_provider.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
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
      _rotationAngle += delta * 0.01;
      _scrollOffset = newOffset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final topPadding = MediaQuery.of(context).padding.top + 68;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: const Color(0xFF1A6B5C),
      body: Stack(
        children: [
          const Positioned.fill(child: UnovaGridBackground()),

          // Contenido principal
          if (favorites.isEmpty)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border, size: 64, color: Colors.white54),
                  const SizedBox(height: 16),
                  const Text(
                    'Aún no tienes favoritos guardados',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Toca el corazón en el detalle de un Pokémon',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: isPortrait
                  ? Stack(
                      children: [
                        ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                          itemCount: favorites.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final pokemon = favorites[index];
                            final region = PokemonRegion.fromPokemonId(pokemon.id);

                            return _buildScaledCard(
                              index: index,
                              pokemonId: pokemon.id,
                              pokemonName: pokemon.name,
                              pokemonTypes: pokemon.types,
                              region: region,
                              spriteUrl: pokemon.spriteUrl,
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
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            final pokemon = favorites[index];
                            final region = PokemonRegion.fromPokemonId(pokemon.id);

                            return _buildScaledBookSpine(
                              index: index,
                              pokemonId: pokemon.id,
                              pokemonName: pokemon.name,
                              pokemonTypes: pokemon.types,
                              region: region,
                              spriteUrl: pokemon.spriteUrl,
                            );
                          },
                        ),
                        _buildPokeballIndicatorHorizontal(),
                      ],
                    ),
            ),

          // Barra superior
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
                  const SizedBox(width: 16),
                  const Text(
                    'Mis Favoritos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScaledCard({
    required int index,
    required int pokemonId,
    required String pokemonName,
    required List pokemonTypes,
    required PokemonRegion region,
    String? spriteUrl,
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
                  spriteUrl: spriteUrl,
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

  Widget _buildScaledBookSpine({
    required int index,
    required int pokemonId,
    required String pokemonName,
    required List pokemonTypes,
    required PokemonRegion region,
    String? spriteUrl,
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
                  spriteUrl: spriteUrl,
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
}
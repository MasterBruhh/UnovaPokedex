import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/frosted_icon_button.dart';
import '../../../../core/widgets/wood_grain_background.dart';
import '../../../pokedex/domain/entities/pokemon_region.dart';
import '../../../pokedex/presentation/widgets/pokemon_list/pokedex_book_spine.dart';
import '../providers/favorites_provider.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final topPadding = MediaQuery.of(context).padding.top + 68;

    return Scaffold(
      backgroundColor: AppColors.woodBrown,
      body: Stack(
        children: [
          const Positioned.fill(child: WoodGrainBackground()),

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
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Mostrar como cuadrícula en favoritos
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final pokemon = favorites[index];
                  final region = PokemonRegion.fromPokemonId(pokemon.id);

                  return PokedexBookSpine(
                    id: pokemon.id,
                    name: pokemon.name,
                    types: pokemon.types,
                    region: region,
                    onTap: () => context.push(
                      '/pokedex/${Uri.encodeComponent(pokemon.name)}',
                    ),
                  );
                },
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
}
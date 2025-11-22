import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/frosted_icon_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/wood_grain_background.dart';
import '../../domain/entities/pokemon_region.dart';
import '../providers/pokemon_list_provider.dart';
import '../widgets/pokemon_list/counter_pill.dart';
import '../widgets/pokemon_list/filter_bottom_sheet.dart';
import '../widgets/pokemon_list/pokedex_book_spine.dart';

/// Página que muestra la lista de Pokémon como lomos de libros
class PokedexListPage extends ConsumerWidget {
  const PokedexListPage({super.key});

  void _openFilterSheet(BuildContext context, WidgetRef ref) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pokemonListProvider);
    final topPadding = MediaQuery.of(context).padding.top + 68;

    return Scaffold(
      backgroundColor: AppColors.woodBrown,
      body: Stack(
        children: [
          const Positioned.fill(child: WoodGrainBackground()),
          Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: _buildBody(context, ref, state),
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
                    onPressed: () => _openFilterSheet(context, ref),
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
    WidgetRef ref,
    PokemonListState state,
  ) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    if (state.error != null) {
      return _buildError(context, ref, state.error!);
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

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: state.filteredPokemon.length,
      itemBuilder: (context, index) {
        final pokemon = state.filteredPokemon[index];
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
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String error) {
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../../core/widgets/frosted_icon_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/wood_grain_background.dart';
import '../providers/pokedex_providers.dart';
import '../providers/pokemon_detail_provider.dart';
import '../widgets/pokemon_detail/evolution_section.dart';
import '../widgets/pokemon_detail/pokemon_abilities_card.dart';
import '../widgets/pokemon_detail/pokemon_header_card.dart';
import '../widgets/pokemon_detail/pokemon_info_card.dart';
import '../widgets/pokemon_detail/pokemon_moves_card.dart';
import '../widgets/pokemon_detail/pokemon_stats_card.dart';

/// Página que muestra información detallada sobre un Pokémon
class PokedexDetailPage extends ConsumerWidget {
  const PokedexDetailPage({
    super.key,
    this.pokemonName,
    this.pokemonId,
  }) : assert(
          pokemonName != null || pokemonId != null,
          'Either pokemonName or pokemonId must be provided',
        );

  final String? pokemonName;
  final int? pokemonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName = pokemonName?.toTitleCase() ?? 'Pokémon';
    final topPadding = MediaQuery.of(context).padding.top + 68;

    // Observar el provider apropiado basado en lo que se proporcionó
    final asyncValue = pokemonName != null
        ? ref.watch(pokemonDetailProvider(pokemonName!))
        : ref.watch(pokemonDetailByIdProvider(pokemonId!));

    return Scaffold(
      backgroundColor: AppColors.woodBrown,
      body: Stack(
        children: [
          const Positioned.fill(child: WoodGrainBackground()),
          Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: _buildBody(context, ref, asyncValue),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: ShapeDecoration(
                        color: AppColors.frostedGlass,
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
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

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue asyncValue,
  ) {
    return asyncValue.when(
      data: (pokemon) => _buildDetail(context, ref, pokemon),
      loading: () => const LoadingIndicator(),
      error: (error, stack) => _buildError(context, ref, error.toString()),
    );
  }

  Widget _buildDetail(
    BuildContext context,
    WidgetRef ref,
    pokemon,
  ) {
    final evolutionUseCase = ref.read(getEvolutionChainUseCaseProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encabezado con imagen e información básica
          PokemonHeaderCard(pokemon: pokemon),
          const SizedBox(height: 16),

          // Descripción
          if (pokemon.description.isNotEmpty)
            PokemonInfoCard(
              title: 'Descripción',
              child: Text(
                pokemon.description,
                style: const TextStyle(color: Colors.white, height: 1.5),
              ),
            ),
          const SizedBox(height: 16),

          // Habilidades
          PokemonInfoCard(
            title: 'Habilidades',
            child: PokemonAbilitiesCard(abilities: pokemon.abilities),
          ),
          const SizedBox(height: 16),

          // Estadísticas
          PokemonInfoCard(
            title: 'Estadísticas Base',
            child: PokemonStatsCard(stats: pokemon.stats),
          ),
          const SizedBox(height: 16),

          // Cadena evolutiva
          if (pokemon.evolutionChain.isNotEmpty)
            PokemonInfoCard(
              title: 'Evoluciones',
              child: EvolutionSection(
                pokemon: pokemon,
                evolutionUseCase: evolutionUseCase,
                onTapSpecies: (name) => context.push(
                  '/pokedex/${Uri.encodeComponent(name)}',
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Movimientos
          PokemonInfoCard(
            title: 'Movimientos por Nivel',
            child: PokemonMovesCard(moves: pokemon.moves),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Error: $error',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                if (pokemonName != null) {
                  ref.invalidate(pokemonDetailProvider(pokemonName!));
                } else if (pokemonId != null) {
                  ref.invalidate(pokemonDetailByIdProvider(pokemonId!));
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

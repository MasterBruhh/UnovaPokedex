import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/share_utils.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../../core/widgets/animated_favorite_button.dart';
import '../../../../core/widgets/cyan_grid_background.dart';
import '../../../../core/widgets/frosted_icon_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/entities/pokemon_detail.dart';
import '../providers/favorites_provider.dart';
import '../providers/pokedex_providers.dart';
import '../providers/pokemon_detail_provider.dart';
import '../widgets/pokemon_detail/combat_tab_content.dart';
import '../widgets/pokemon_detail/description_tab_content.dart';
import '../widgets/pokemon_detail/detail_tab_bar.dart';
import '../widgets/pokemon_detail/forms_tab_content.dart';
import '../widgets/pokemon_detail/pokemon_header_card.dart';
import '../widgets/pokemon_detail/pokemon_share_card.dart';

/// Página que muestra información detallada sobre un Pokémon.
/// Convertido a ConsumerStatefulWidget para manejar el GlobalKey de la captura.
class PokedexDetailPage extends ConsumerStatefulWidget { // CORREGIDO AQUÍ
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
  ConsumerState<PokedexDetailPage> createState() => _PokedexDetailPageState();
}

class _PokedexDetailPageState extends ConsumerState<PokedexDetailPage> {
  // Key global para identificar el widget que queremos capturar como imagen
  final GlobalKey _shareCardKey = GlobalKey();
  
  // Pestaña seleccionada actualmente
  DetailTab _selectedTab = DetailTab.descripcion;

  @override
  Widget build(BuildContext context) {
    final displayName = widget.pokemonName?.toTitleCase() ?? 'Pokémon';
    final topPadding = MediaQuery.of(context).padding.top + 68;

    final asyncValue = widget.pokemonName != null
        ? ref.watch(pokemonDetailProvider(widget.pokemonName!))
        : ref.watch(pokemonDetailByIdProvider(widget.pokemonId!));

    return Scaffold(
      backgroundColor: const Color(0xFF4A8B8B),
      body: Stack(
        children: [
          const Positioned.fill(child: CyanGridBackground()),

          // --- WIDGET OCULTO PARA CAPTURA ---
          // Esto renderiza la tarjeta fuera de la vista del usuario
          // para que pueda ser capturada por el RepaintBoundary.
          if (asyncValue.hasValue)
            Positioned(
              left: -9999, // Mover fuera de la pantalla
              child: RepaintBoundary(
                key: _shareCardKey,
                child: PokemonShareCard(pokemon: asyncValue.value!),
              ),
            ),
          // --------------------------------

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
                  const SizedBox(width: 12),

                  // --- BOTONES DE ACCIÓN ---
                  asyncValue.maybeWhen(
                    data: (details) {
                      // Verificar si está en favoritos usando el provider
                      final isFav = ref.watch(favoritesProvider).any((p) => p.id == details.id);

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Botón Compartir (NUEVO)
                          FrostedIconButton(
                            icon: Icons.share,
                            onPressed: () {
                              // Llamar a la función utilitaria para capturar y compartir
                              ShareUtils.captureAndShareWidget(
                                globalKey: _shareCardKey,
                                fileName: 'pokemon_${details.name}',
                                text: '¡Mira las estadísticas de ${details.name.toTitleCase()} en mi Unova Pokedex!',
                              );
                            },
                            tooltip: 'Compartir tarjeta',
                          ),
                          const SizedBox(width: 8),
                          // Botón Favoritos con animación
                          AnimatedFavoriteButton(
                            isFavorite: isFav,
                            onPressed: () {
                              final pokemonSummary = Pokemon(
                                id: details.id,
                                name: details.name,
                                types: details.types,
                              );
                              ref.read(favoritesProvider.notifier).toggleFavorite(pokemonSummary);
                            },
                            tooltip: isFav ? 'Quitar de favoritos' : 'Agregar a favoritos',
                          ),
                        ],
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
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
      PokemonDetail pokemon,
      ) {
    final evolutionUseCase = ref.read(getEvolutionChainUseCaseProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card con imagen, nombre, tipos, altura y peso
          PokemonHeaderCard(pokemon: pokemon),
          const SizedBox(height: 16),
          
          // Barra de pestañas
          DetailTabBar(
            selectedTab: _selectedTab,
            onTabSelected: (tab) {
              setState(() {
                _selectedTab = tab;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Contenido según la pestaña seleccionada
          _buildTabContent(context, pokemon, evolutionUseCase),
          
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    PokemonDetail pokemon,
    evolutionUseCase,
  ) {
    switch (_selectedTab) {
      case DetailTab.descripcion:
        return DescriptionTabContent(pokemon: pokemon);
      case DetailTab.formas:
        return FormsTabContent(
          pokemon: pokemon,
          evolutionUseCase: evolutionUseCase,
          onTapSpecies: (name) => context.pushReplacement(
            '/pokedex/${Uri.encodeComponent(name)}',
          ),
          onTapForm: (form) {
            // Navegar al detalle de la forma usando su nombre
            context.pushReplacement(
              '/pokedex/${Uri.encodeComponent(form.name)}',
            );
          },
        );
      case DetailTab.combate:
        return CombatTabContent(pokemon: pokemon);
    }
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
                if (widget.pokemonName != null) {
                  ref.invalidate(pokemonDetailProvider(widget.pokemonName!));
                } else if (widget.pokemonId != null) {
                  ref.invalidate(pokemonDetailByIdProvider(widget.pokemonId!));
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
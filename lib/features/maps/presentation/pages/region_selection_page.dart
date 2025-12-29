import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/purple_grid_background.dart';
import '../../../pokedex/presentation/utils/pokemon_region_colors.dart';
import '../../../pokedex/domain/entities/pokemon_region.dart';
import '../../domain/entities/region_config.dart';

/// Pantalla de selección de región
/// 
/// Muestra una lista de todas las regiones Pokémon disponibles.
/// Soporta orientaciones portrait y landscape con layouts adaptativos.
class RegionSelectionPage extends ConsumerWidget {
  const RegionSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A2B5C),
      appBar: AppBar(
        title: const Text(
          'Pokémon Regions',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: PurpleGridBackground()),
          OrientationBuilder(
            builder: (context, orientation) {
              final isPortrait = orientation == Orientation.portrait;
              
              return isPortrait
                  ? _buildPortraitLayout(context)
                  : _buildLandscapeLayout(context);
            },
          ),
        ],
      ),
    );
  }

  /// Layout vertical (portrait)
  Widget _buildPortraitLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.map, size: 80, color: Color(0xFF9B7CB5)),
            const SizedBox(height: 20),
            const Text(
              'Select a Region',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            ..._buildRegionCards(context).expand(
              (widget) => [widget, const SizedBox(height: 20)],
            ),
          ],
        ),
      ),
    );
  }

  /// Layout horizontal (landscape)
  Widget _buildLandscapeLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.map, size: 60, color: Color(0xFF9B7CB5)),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Select a Region',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.35,
              children: _buildRegionCards(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye las tarjetas de regiones desde la configuración
  List<Widget> _buildRegionCards(BuildContext context) {
    return RegionConfig.allRegions.map((config) {
      return _buildRegionCard(
        context,
        config: config,
        onTap: () {
          // Navegar usando GoRouter con el nombre de la región
          context.pushNamed(
            'map_detail',
            pathParameters: {'region': config.name.toLowerCase()},
          );
        },
      );
    }).toList();
  }

  /// Construye una tarjeta individual de región
  Widget _buildRegionCard(
    BuildContext context, {
    required RegionConfig config,
    required VoidCallback onTap,
  }) {
    // Mapear nombre de región a PokemonRegion para obtener el color
    final regionColor = _getRegionColor(config.name);

    return InkWell(
      onTap: config.isLocked ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Tab de carpeta - sobresale arriba
          Positioned(
            top: -8,
            left: 12,
            child: Container(
              width: 100,
              height: 35,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                border: Border.all(
                  color: Colors.black.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
          ),
          // Cuerpo principal de la carpeta
          Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.black.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  config.icon,
                  size: 50,
                  color: config.isLocked ? Colors.grey : regionColor,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        config.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: config.isLocked ? Colors.grey : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        config.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: config.isLocked ? Colors.grey : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  config.isLocked ? Icons.lock : Icons.arrow_forward_ios,
                  color: config.isLocked ? Colors.grey : Colors.white70,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRegionColor(String regionName) {
    switch (regionName.toLowerCase()) {
      case 'kanto':
        return PokemonRegionColors.getColor(PokemonRegion.kanto);
      case 'johto':
        return PokemonRegionColors.getColor(PokemonRegion.johto);
      case 'hoenn':
        return PokemonRegionColors.getColor(PokemonRegion.hoenn);
      case 'sinnoh':
        return PokemonRegionColors.getColor(PokemonRegion.sinnoh);
      case 'unova':
        return PokemonRegionColors.getColor(PokemonRegion.unova);
      case 'kalos':
        return PokemonRegionColors.getColor(PokemonRegion.kalos);
      default:
        return Colors.grey;
    }
  }
}

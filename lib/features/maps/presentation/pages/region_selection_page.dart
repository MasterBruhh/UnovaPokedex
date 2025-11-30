import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      appBar: AppBar(
        title: const Text('Pokémon Regions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;
          
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade200,
                  Colors.green.shade200,
                ],
              ),
            ),
            child: isPortrait
                ? _buildPortraitLayout(context)
                : _buildLandscapeLayout(context),
          );
        },
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
            const Icon(Icons.map, size: 80, color: Colors.white),
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
              Icon(Icons.map, size: 60, color: Colors.white),
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
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: config.isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          child: Row(
            children: [
              Icon(
                config.icon,
                size: 50,
                color: config.isLocked ? Colors.grey : Colors.red.shade700,
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
                        color: config.isLocked ? Colors.grey : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      config.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: config.isLocked ? Colors.grey : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                config.isLocked ? Icons.lock : Icons.arrow_forward_ios,
                color: config.isLocked ? Colors.grey : Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/audio/audio_controller.dart';
import '../../../../core/config/app_constants.dart';
import '../widgets/menu_tile.dart';
import '../widgets/pokedex_tile.dart';

/// Página del menú principal de la aplicación
class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  @override
  void initState() {
    super.initState();
    // Iniciar música de fondo después de que termine el SFX del splash
    Future.microtask(() async {
      await AudioController.instance.startBgmAfterSfx(
        AppConstants.pokemonCenterBgmPath,
        targetVolume: 0.55,
        fadeIn: const Duration(milliseconds: 1200),
        overlap: const Duration(milliseconds: 120),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const spacing = 16.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Menú')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columnWidth = (constraints.maxWidth - spacing) / 2;

          // Definir elementos del menú y sus alturas
          final items = <_TileSpec>[
            _TileSpec(
              title: 'Mapa',
              icon: Icons.map,
              height: columnWidth,
              onTap: () => context.pushNamed('maps'),
            ),
            _TileSpec(
              title: 'Trivia',
              icon: Icons.article,
              height: columnWidth * 1.2,
              onTap: () {
                // TODO: Implement trivia feature
              },
            ),

            // --- PASO 6: Botón de Acceso a Favoritos ---
            _TileSpec(
              title: 'Favoritos',
              icon: Icons.favorite,
              height: columnWidth, // Altura cuadrada para equilibrar el grid
              onTap: () => context.pushNamed('favorites'),
            ),
            // ------------------------------------------
          ];

          // Distribuir elementos entre columnas izquierda y derecha
          final left = <_TileSpec>[];
          final right = <_TileSpec>[];
          for (var i = 0; i < items.length; i++) {
            (i % 2 == 0 ? left : right).add(items[i]);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tile de pokédex - ancho completo en la parte superior
                PokedexTile(
                  height: 250,
                  onTap: () => context.pushNamed('pokedex'),
                ),
                const SizedBox(height: spacing),

                // Diseño de dos columnas para otros elementos del menú
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildColumn(left, spacing)),
                    const SizedBox(width: spacing),
                    Expanded(child: _buildColumn(right, spacing)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildColumn(List<_TileSpec> items, double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          MenuTile.fixedHeight(
            title: items[i].title,
            icon: items[i].icon,
            height: items[i].height,
            onTap: items[i].onTap,
          ),
          if (i != items.length - 1) SizedBox(height: spacing),
        ]
      ],
    );
  }
}

/// Clase interna para especificar propiedades de los tiles
class _TileSpec {
  const _TileSpec({
    required this.title,
    required this.icon,
    required this.height,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final double height;
  final VoidCallback onTap;
}
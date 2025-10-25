import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/audio_controller.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  @override
  void initState() {
    super.initState();
    // No cortamos el SFX: esperamos a que termine y luego subimos el BGM del menú con fade-in.
    Future.microtask(() async {
      await AudioController.instance.startBgmAfterSfx(
        'audio/pokemon_center.mp3',
        targetVolume: 0.55,
        fadeIn: const Duration(milliseconds: 1200),
        overlap: const Duration(milliseconds: 120), // leve solape opcional (ajustable)
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

          // Aquí se definen los ítems inferiores y su alto deseado (en función del ancho de columna)
          final items = <_TileSpec>[
            _TileSpec(
              title: 'Mapa',
              icon: Icons.map,
              height: columnWidth, // cuadrado
              onTap: () {},
            ),
            _TileSpec(
              title: 'Trivia',
              icon: Icons.article,
              height: columnWidth * 1.2, // rectángulo vertical
              onTap: () {},
            ),
            // Aquí se agrega manualmente; se alternan izquierda/derecha automáticamente
            // _TileSpec(title: 'Otro', icon: Icons.extension, height: columnWidth * 0.9, onTap: () {}),
          ];

          final left = <_TileSpec>[];
          final right = <_TileSpec>[];
          for (var i = 0; i < items.length; i++) {
            (i % 2 == 0 ? left : right).add(items[i]);
          }

          Widget buildColumn(List<_TileSpec> list) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < list.length; i++) ...[
                    MenuTile.fixedHeight(
                      title: list[i].title,
                      icon: list[i].icon,
                      height: list[i].height,
                      onTap: list[i].onTap,
                    ),
                    if (i != list.length - 1) const SizedBox(height: spacing),
                  ]
                ],
              );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Item superior de Pokedex, ocupa todo el ancho y muestra imagen en lugar de título
                PokedexTile(
                  height: 250,
                  onTap: () => context.pushNamed('pokedex'),
                ),
                const SizedBox(height: spacing),

                // Dos columnas: izquierda/derecha; se alterna por índice
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: buildColumn(left)),
                    const SizedBox(width: spacing),
                    Expanded(child: buildColumn(right)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  const MenuTile._({
    required this.title,
    required this.icon,
    required this.onTap,
    this.height,
    this.size,
    this.expand = false,
    this.child,
    this.showHeader = true,
  });

  factory MenuTile.expand({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    double height = 160,
    Widget? child,
    bool showHeader = true,
  }) =>
      MenuTile._(
        title: title,
        icon: icon,
        onTap: onTap,
        height: height,
        expand: true,
        child: child,
        showHeader: showHeader,
      );

  factory MenuTile.fixed({
    required String title,
    required IconData icon,
    required Size size,
    required VoidCallback onTap,
    Widget? child,
    bool showHeader = true,
  }) =>
      MenuTile._(
        title: title,
        icon: icon,
        onTap: onTap,
        size: size,
        child: child,
        showHeader: showHeader,
      );

  // Ancho se adapta a la columna, alto fijo personalizado
  factory MenuTile.fixedHeight({
    required String title,
    required IconData icon,
    required double height,
    required VoidCallback onTap,
    Widget? child,
    bool showHeader = true,
  }) =>
      MenuTile._(
        title: title,
        icon: icon,
        onTap: onTap,
        height: height,
        expand: true,
        child: child,
        showHeader: showHeader,
      );

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final double? height; // usado cuando expand == true
  final Size? size; // usado cuando expand == false
  final bool expand;
  final Widget? child;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final header = showHeader
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
            ],
          )
        : const SizedBox.shrink();

    final content = Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              Expanded(
                child: Center(
                  child: child ?? Icon(
                        icon,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (expand) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: content,
      );
    }

    return SizedBox.fromSize(size: size, child: content);
  }
}

class PokedexTile extends StatelessWidget {
  const PokedexTile({super.key, required this.height, required this.onTap});

  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _TileSpec {
  final String title;
  final IconData icon;
  final double height;
  final VoidCallback onTap;
  _TileSpec({
    required this.title,
    required this.icon,
    required this.height,
    required this.onTap,
  });
}

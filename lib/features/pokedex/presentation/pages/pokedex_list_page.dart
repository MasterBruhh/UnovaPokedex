import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PokedexListPage extends StatefulWidget {
  const PokedexListPage({super.key});

  @override
  State<PokedexListPage> createState() => _PokedexListPageState();
}

class _PokedexListPageState extends State<PokedexListPage> {
  // Contador dependiente de filtros: por ahora placeholder (sin filtros aplicados)
  int _filteredCount = 15;

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filtros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                SizedBox(height: 12),
                Text('Próximamente', style: TextStyle(fontSize: 16)),
                SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Se dibuja encima del fondo de madera
      body: Stack(
        children: [
          // Fondo de madera
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0xFF6D4C41),
              child: _WoodGrainBackground(),
            ),
          ),

          // Encabezado translúcido sobre el fondo de madera
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  _FrostedIconButton(
                    icon: Icons.arrow_back,
                    onPressed: () => context.pop(),
                    tooltip: 'Volver',
                  ),
                  const SizedBox(width: 8),

                  // Contador (izquierda)
                  _CounterPill(count: _filteredCount),

                  const Spacer(),

                  // Filtros (derecha)
                  _FrostedIconButton(
                    icon: Icons.filter_list_rounded,
                    onPressed: _openFilterSheet,
                    tooltip: 'Filtros',
                  ),
                ],
              ),
            ),
          ),

          // Contenido principal (placeholder hasta integrar PokeAPI)
          const _PokedexEmptyState(),
        ],
      ),
      backgroundColor: const Color(0xFF6D4C41),
    );
  }
}

class _FrostedIconButton extends StatelessWidget {
  const _FrostedIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final bg = Colors.black.withValues(alpha: 0.20);
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const StadiumBorder(),
          child: Container(
            decoration: ShapeDecoration(
              color: bg,
              shape: const StadiumBorder(),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _CounterPill extends StatelessWidget {
  const _CounterPill({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final bg = Colors.black.withValues(alpha: 0.20);
    return Container(
      decoration: ShapeDecoration(
        color: bg,
        shape: const StadiumBorder(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.menu_book, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _PokedexEmptyState extends StatelessWidget {
  const _PokedexEmptyState();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // mensaje placeholder
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book, color: Colors.white, size: 56),
                const SizedBox(height: 12),
                Text(
                  'Preparado para integrar PokeAPI',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Aquí se listarán los Pokémon en formato de libro.\nConectaremos con PokeAPI y aplicaremos filtros.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Fondo con vetas de madera + color base
class _WoodGrainBackground extends StatelessWidget {
  const _WoodGrainBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: Color(0xFF6D4C41))),
        Positioned.fill(
          child: Opacity(
            opacity: 0.15,
            child: CustomPaint(painter: _WoodGrainPainter()),
          ),
        ),
      ],
    );
  }
}

class _WoodGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    for (double x = -20; x < size.width + 20; x += 60) {
      canvas.drawPath(
        Path()
          ..moveTo(x, 0)
          ..cubicTo(x + 15, size.height * 0.25, x - 10, size.height * 0.6, x + 10, size.height)
          ..lineTo(x + 20, size.height)
          ..cubicTo(x + 35, size.height * 0.65, x + 10, size.height * 0.3, x + 30, 0),
        paint..color = Colors.brown.shade300,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// TODO: Colores por tipo y región (a implementar más adelante)

/*Color typeColor(PokeType t) {
  switch (t) {
    case PokeType.normal:
      return const Color(0xFFA8A77A);
    case PokeType.fire:
      return const Color(0xFFEE8130);
    case PokeType.water:
      return const Color(0xFF6390F0);
    case PokeType.electric:
      return const Color(0xFFF7D02C);
    case PokeType.grass:
      return const Color(0xFF7AC74C);
    case PokeType.ice:
      return const Color(0xFF96D9D6);
    case PokeType.fighting:
      return const Color(0xFFC22E28);
    case PokeType.poison:
      return const Color(0xFFA33EA1);
    case PokeType.ground:
      return const Color(0xFFE2BF65);
    case PokeType.flying:
      return const Color(0xFFA98FF3);
    case PokeType.psychic:
      return const Color(0xFFF95587);
    case PokeType.bug:
      return const Color(0xFFA6B91A);
    case PokeType.rock:
      return const Color(0xFFB6A136);
    case PokeType.ghost:
      return const Color(0xFF735797);
    case PokeType.dragon:
      return const Color(0xFF6F35FC);
    case PokeType.dark:
      return const Color(0xFF705746);
    case PokeType.steel:
      return const Color(0xFFB7B7CE);
    case PokeType.fairy:
      return const Color(0xFFD685AD);
  }
}*/

/*
Color regionColor(PokeRegion r) {
  switch (r) {
    case PokeRegion.kanto:
      return const Color(0xFF9CCC65);
    case PokeRegion.johto:
      return const Color(0xFFFFCA28);
    case PokeRegion.hoenn:
      return const Color(0xFF26C6DA);
    case PokeRegion.sinnoh:
      return const Color(0xFF9575CD);
    case PokeRegion.unova:
      return const Color(0xFF90A4AE);
    case PokeRegion.kalos:
      return const Color(0xFF42A5F5);
    case PokeRegion.alola:
      return const Color(0xFFFF7043);
    case PokeRegion.galar:
      return const Color(0xFFEC407A);
    case PokeRegion.paldea:
      return const Color(0xFF66BB6A);
    case PokeRegion.hisui:
      return const Color(0xFF26A69A);
  }
}*/

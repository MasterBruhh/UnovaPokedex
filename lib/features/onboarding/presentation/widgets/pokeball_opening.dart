import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/audio/audio_controller.dart';

/// Widget que muestra una Pokéball animada que se abre al tocarla
class PokeballOpening extends StatefulWidget {
  const PokeballOpening({
    super.key,
    this.size = 180,
    required this.onOpened,
    this.sfxVolume = 0.4,
  });

  final double size;
  final VoidCallback onOpened;
  final double sfxVolume;

  @override
  State<PokeballOpening> createState() => _PokeballOpeningState();
}

class _PokeballOpeningState extends State<PokeballOpening>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _open() async {
    if (_controller.isAnimating) return;

    final volume = widget.sfxVolume.clamp(0.0, 1.0);
    AudioController.instance.playSfxAsset(
      'audio/pokeball_sound.mp3',
      volume: volume,
    );

    await _controller.forward();
    widget.onOpened();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _open,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, _) => CustomPaint(
            painter: _PokeballPainter(progress: _progress.value),
          ),
        ),
      ),
    );
  }
}

/// Pintor personalizado para la animación de la Pokéball
class _PokeballPainter extends CustomPainter {
  _PokeballPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2.0;

    final red = const Color(0xFFE3350D);
    final black = Colors.black;

    final paintRed = Paint()..color = red;
    final paintWhite = Paint()..color = Colors.white;
    final paintStroke = Paint()
      ..color = black
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.08
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Curva de apertura suave
    final sepCurve = Curves.easeInOutCubic.transform(progress);
    final separation = radius * 0.55 * sepCurve;

    // Dibujar sombras
    void drawShadowAt(Offset c) {
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(c, radius * 0.98, shadowPaint);
    }

    drawShadowAt(center.translate(0, separation * 0.25));
    drawShadowAt(center.translate(0, -separation * 0.15));

    // Preparar paths de semicírculo
    final circleRect = Rect.fromCircle(center: Offset.zero, radius: radius);
    final topPath = Path()
      ..moveTo(0, 0)
      ..addArc(circleRect, math.pi, math.pi)
      ..close();
    final bottomPath = Path()
      ..moveTo(0, 0)
      ..addArc(circleRect, 0, math.pi)
      ..close();

    // Mitad superior (roja)
    canvas.save();
    canvas.translate(center.dx, center.dy - separation);
    canvas.save();
    canvas.clipPath(topPath);
    canvas.drawCircle(Offset.zero, radius, paintRed);
    canvas.restore();
    final topArc = Path()..addArc(circleRect, math.pi, math.pi);
    canvas.drawPath(topArc, paintStroke);
    canvas.restore();

    // Mitad inferior (blanca)
    canvas.save();
    canvas.translate(center.dx, center.dy + separation);
    canvas.save();
    canvas.clipPath(bottomPath);
    canvas.drawCircle(Offset.zero, radius, paintWhite);
    canvas.restore();
    final bottomArc = Path()..addArc(circleRect, 0, math.pi);
    canvas.drawPath(bottomArc, paintStroke);
    canvas.restore();

    // Banda central
    final bandFade = (1.0 - (progress * 1.6)).clamp(0.0, 1.0);
    final bandHeight = radius * 0.18 * (0.9 + 0.1 * (1 - progress));
    if (bandFade > 0.0) {
      final bandPaint = Paint()
        ..color = black.withOpacity(0.85 * bandFade)
        ..style = PaintingStyle.fill;
      final bandRect = Rect.fromCenter(
        center: center,
        width: radius * 2.0,
        height: bandHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bandRect, Radius.circular(bandHeight / 2)),
        bandPaint,
      );
    }

    // Botón central
    final extraLift = radius * 0.06 * Curves.easeOut.transform(progress);
    final buttonCenter = center.translate(0, -separation - extraLift);
    final popScale = 1.0 + 0.08 * (1.0 - Curves.easeOut.transform(progress));
    final buttonR = radius * 0.26 * popScale;

    // Halo del botón
    final haloAlpha = (1 - progress) * 0.6;
    if (haloAlpha > 0) {
      final haloPaint = Paint()
        ..color = Colors.white.withOpacity(haloAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(buttonCenter, buttonR * 1.05, haloPaint);
    }

    // Botón
    canvas.drawCircle(buttonCenter, buttonR, Paint()..color = Colors.white);
    canvas.drawCircle(buttonCenter, buttonR, paintStroke);
  }

  @override
  bool shouldRepaint(_PokeballPainter oldDelegate) =>
      oldDelegate.progress != progress;
}


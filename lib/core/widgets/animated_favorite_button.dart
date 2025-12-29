import 'package:flutter/material.dart';
import 'dart:ui';

/// Botón de favoritos con animación de corazón que pulsa y partículas
class AnimatedFavoriteButton extends StatefulWidget {
  const AnimatedFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
    this.size = 24.0,
    this.tooltip,
  });

  final bool isFavorite;
  final VoidCallback onPressed;
  final double size;
  final String? tooltip;

  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _particleAnimation;

  bool _wasPressed = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_scaleController);

    _particleAnimation = CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedFavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animar cuando cambia el estado de favorito
    if (oldWidget.isFavorite != widget.isFavorite && _wasPressed) {
      _scaleController.forward(from: 0);
      if (widget.isFavorite) {
        _particleController.forward(from: 0);
      }
      _wasPressed = false;
    }
  }

  void _handlePress() {
    _wasPressed = true;
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final button = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withValues(alpha: 0.15),
          child: InkWell(
            onTap: _handlePress,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: AnimatedBuilder(
                animation: Listenable.merge([_scaleAnimation, _particleAnimation]),
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Partículas que explotan
                      if (_particleController.isAnimating || _particleController.value > 0)
                        ..._buildParticles(),
                      
                      // Icono del corazón
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: Icon(
                            widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                            key: ValueKey(widget.isFavorite),
                            color: widget.isFavorite ? Colors.red : Colors.white,
                            size: widget.size,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }

  List<Widget> _buildParticles() {
    final particles = <Widget>[];
    const particleCount = 8;
    final progress = _particleAnimation.value;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 3.14159 * 2;
      final distance = 20.0 * progress;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      particles.add(
        Positioned(
          left: distance * (1 + 0.5 * (i % 2 == 0 ? 1 : -1)) * 
                (angle < 3.14159 ? 1 : -1).toDouble() * 
                (i % 3 == 0 ? 0.8 : 1.2),
          top: distance * (angle > 1.57 && angle < 4.71 ? -1 : 1).toDouble() *
               (i % 2 == 0 ? 0.9 : 1.1),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 4 + (2 * (1 - progress)),
              height: 4 + (2 * (1 - progress)),
              decoration: BoxDecoration(
                color: _particleColors[i % _particleColors.length],
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      );
    }

    return particles;
  }

  static const _particleColors = [
    Colors.red,
    Colors.pink,
    Colors.orange,
    Colors.yellow,
    Colors.redAccent,
    Colors.pinkAccent,
    Colors.deepOrange,
    Colors.amber,
  ];
}

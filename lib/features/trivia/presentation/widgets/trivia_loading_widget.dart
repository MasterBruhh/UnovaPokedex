import 'package:flutter/material.dart';

import '../../theme/trivia_colors.dart';

/// Widget de carga reutilizable con estilo temático de Pokémon.
/// 
/// Muestra un indicador de carga centrado con mensaje opcional.
class TriviaLoadingWidget extends StatelessWidget {
  /// Mensaje opcional a mostrar debajo del spinner
  final String? message;
  
  /// Tamaño del indicador de carga
  final double size;

  const TriviaLoadingWidget({
    super.key,
    this.message,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              color: TriviaColors.primary,
              strokeWidth: 4,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 24),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget de carga animado con efecto de Pokéball rebotando.
class PokemonLoadingWidget extends StatefulWidget {
  /// Mensaje opcional a mostrar
  final String? message;

  const PokemonLoadingWidget({
    super.key,
    this.message,
  });

  @override
  State<PokemonLoadingWidget> createState() => _PokemonLoadingWidgetState();
}

class _PokemonLoadingWidgetState extends State<PokemonLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _bounceAnimation.value),
                child: child,
              );
            },
            child: const Icon(
              Icons.catching_pokemon,
              size: 80,
              color: TriviaColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          if (widget.message != null)
            Text(
              widget.message!,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

/// Widget de error reutilizable con funcionalidad de reintentar.
class TriviaErrorWidget extends StatelessWidget {
  /// El mensaje de error a mostrar
  final String message;
  
  /// Callback opcional para acción de reintentar
  final VoidCallback? onRetry;
  
  /// Ícono opcional a mostrar
  final IconData icon;

  const TriviaErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: TriviaColors.error.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: TriviaColors.error,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '¡Oops!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TriviaColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../theme/trivia_colors.dart';

/// Widget que muestra una imagen de Pokémon como silueta o revelada.
/// 
/// Usado en el tipo de pregunta "¿Quién es ese Pokémon?".
/// La silueta es una versión de sombra negra del sprite del Pokémon.
class PokemonSilhouette extends StatelessWidget {
  /// URL de la imagen del sprite del Pokémon
  final String imageUrl;
  
  /// Tamaño de la imagen (ancho y alto)
  final double size;
  
  /// Si se debe mostrar la versión revelada (con color)
  final bool isRevealed;
  
  /// Duración de la animación de revelación
  final Duration animationDuration;

  const PokemonSilhouette({
    super.key,
    required this.imageUrl,
    this.size = 200,
    this.isRevealed = false,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeInOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isRevealed 
                ? TriviaColors.accent.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ColorFiltered(
          colorFilter: isRevealed
              ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
              : const ColorFilter.mode(Colors.black, BlendMode.srcATop),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: size,
            height: size,
            fit: BoxFit.contain,
            placeholder: (context, url) => _buildPlaceholder(),
            errorWidget: (context, url, error) => _buildErrorWidget(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: TriviaColors.primary,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(
          Icons.error_outline,
          color: TriviaColors.error,
          size: 48,
        ),
      ),
    );
  }
}

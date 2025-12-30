import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Widget que muestra un sprite de Pokémon
/// Puede cargar desde una URL remota o desde un archivo local
class PokemonSpriteImage extends StatelessWidget {
  const PokemonSpriteImage({
    super.key,
    required this.imageSource,
    this.height = 48,
    this.width = 48,
    this.fit = BoxFit.contain,
    this.errorIconSize = 40,
  });

  /// Fuente de la imagen: puede ser una URL (http/https) o una ruta de archivo local
  final String imageSource;
  final double height;
  final double width;
  final BoxFit fit;
  final double errorIconSize;

  /// Determina si la fuente es una URL remota o un archivo local
  bool get _isNetworkImage => 
      imageSource.startsWith('http://') || imageSource.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (_isNetworkImage) {
      return Image.network(
        imageSource,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: _buildErrorWidget,
      );
    } else {
      // Es una ruta de archivo local
      return Image.file(
        File(imageSource),
        height: height,
        width: width,
        fit: fit,
        errorBuilder: _buildErrorWidget,
      );
    }
  }

  Widget _buildErrorWidget(BuildContext context, Object error, StackTrace? stackTrace) {
    return Icon(
      Icons.catching_pokemon,
      size: errorIconSize,
      color: AppColors.mediumBrown,
    );
  }
}

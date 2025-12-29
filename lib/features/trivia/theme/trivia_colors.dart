import 'package:flutter/material.dart';

/// Colores específicos para el módulo de Trivia.
/// 
/// Estos colores complementan la paleta principal de la app
/// y proporcionan un tema visual distintivo para el juego.
abstract class TriviaColors {
  // Colores primarios de Trivia
  static const Color primary = Color(0xFFE3350D); // Pokémon Red
  static const Color primaryDark = Color(0xFFB52A0A);
  static const Color primaryLight = Color(0xFFFF5733);

  // Colores secundarios
  static const Color secondary = Color(0xFF3B4CCA); // Pokémon Blue
  static const Color secondaryDark = Color(0xFF2A3799);
  static const Color secondaryLight = Color(0xFF5B6CE0);

  // Colores de acento
  static const Color accent = Color(0xFFFFDE00); // Pokémon Yellow
  static const Color accentDark = Color(0xFFCCB200);
  static const Color accentLight = Color(0xFFFFE84D);

  // Colores de fondo
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2D2D44);

  // Colores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFE0E0E0);

  // Colores de feedback
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Colores específicos del juego
  static const Color silhouette = Color(0xFF000000);
  static const Color correctAnswer = Color(0xFF4CAF50);
  static const Color wrongAnswer = Color(0xFFF44336);
  static const Color optionDefault = Color(0xFF3B4CCA);
  static const Color optionHover = Color(0xFF5B6CE0);
  static const Color optionDisabled = Color(0xFF9E9E9E);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  static const LinearGradient pokemonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );
}

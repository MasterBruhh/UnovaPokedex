import 'package:flutter/material.dart';

/// Paleta de colores de la aplicación con nombres semánticos
class AppColors {
  // Constructor privado para prevenir instanciación
  AppColors._();

  // Colores de fondo
  static const Color woodBrown = Color(0xFF6D4C41);
  static const Color beige = Color(0xFFF5F5DC);
  static const Color darkBrown = Color(0xFF5D4037);
  static const Color mediumBrown = Color(0xFF8D6E63);

  // Colores de tipos de Pokémon
  static const Color typeNormal = Color(0xFFA8A77A);
  static const Color typeFire = Color(0xFFEE8130);
  static const Color typeWater = Color(0xFF6390F0);
  static const Color typeElectric = Color(0xFFF7D02C);
  static const Color typeGrass = Color(0xFF7AC74C);
  static const Color typeIce = Color(0xFF96D9D6);
  static const Color typeFighting = Color(0xFFC22E28);
  static const Color typePoison = Color(0xFFA33EA1);
  static const Color typeGround = Color(0xFFE2BF65);
  static const Color typeFlying = Color(0xFFA98FF3);
  static const Color typePsychic = Color(0xFFF95587);
  static const Color typeBug = Color(0xFFA6B91A);
  static const Color typeRock = Color(0xFFB6A136);
  static const Color typeGhost = Color(0xFF735797);
  static const Color typeDragon = Color(0xFF6F35FC);
  static const Color typeDark = Color(0xFF705746);
  static const Color typeSteel = Color(0xFFB7B7CE);
  static const Color typeFairy = Color(0xFFD685AD);

  // Colores de regiones de Pokémon
  static const Color regionKanto = Color(0xFF9CCC65);
  static const Color regionJohto = Color(0xFFFFCA28);
  static const Color regionHoenn = Color(0xFF26C6DA);
  static const Color regionSinnoh = Color(0xFF9575CD);
  static const Color regionUnova = Color(0xFF90A4AE);
  static const Color regionKalos = Color(0xFF42A5F5);
  static const Color regionAlola = Color(0xFFFF7043);
  static const Color regionGalar = Color(0xFFEC407A);
  static const Color regionPaldea = Color(0xFF66BB6A);
  static const Color regionHisui = Color(0xFF26A69A);

  // Colores de barras de estadísticas
  static const Color statHighGreen = Colors.green;
  static const Color statMediumYellow = Colors.yellow;
  static const Color statLowRed = Colors.red;

  // Colores de overlay de UI
  static Color get frostedGlass => Colors.black.withOpacity(0.20);
  static Color get cardOverlay => Colors.white.withOpacity(0.15);
  static Color get cardOverlayLight => Colors.white.withOpacity(0.10);
}


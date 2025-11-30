import 'package:flutter/material.dart';

/// Configuración inmutable de una región de Pokémon
/// 
/// Centraliza toda la información necesaria para renderizar un mapa interactivo:
/// - Metadatos de la región (nombre, descripción)
/// - Rutas de assets (imagen y archivo de datos)
/// - Dimensiones originales del mapa (para cálculos de coordenadas)
class RegionConfig {
  /// Nombre de la región (ej: "Kanto", "Johto")
  final String name;
  
  /// Descripción breve de la región
  final String description;
  
  /// Ícono representativo
  final IconData icon;
  
  /// Ruta del asset de la imagen del mapa
  final String mapImagePath;
  
  /// Ruta del asset con datos de áreas interactivas (formato HTML)
  final String mapDataPath;
  
  /// Ancho original de la imagen del mapa en píxeles
  final double originalWidth;
  
  /// Alto original de la imagen del mapa en píxeles
  final double originalHeight;
  
  /// Si la región está disponible (para futuras expansiones)
  final bool isLocked;

  const RegionConfig({
    required this.name,
    required this.description,
    required this.icon,
    required this.mapImagePath,
    required this.mapDataPath,
    required this.originalWidth,
    required this.originalHeight,
    this.isLocked = false,
  });

  /// Aspect ratio de la imagen original
  double get aspectRatio => originalWidth / originalHeight;
  
  /// Determina si el mapa es vertical (portrait) u horizontal (landscape)
  bool get isVertical => originalHeight > originalWidth;

  // ============================================================================
  // CONFIGURACIÓN DE TODAS LAS REGIONES
  // ============================================================================

  /// Región Kanto - La región original de la primera generación
  static const RegionConfig kanto = RegionConfig(
    name: 'Kanto',
    description: 'The original region',
    icon: Icons.location_on,
    mapImagePath: 'assets/maps/images/kanto.png',
    mapDataPath: 'assets/maps/kanto_map.txt',
    originalWidth: 200.0,
    originalHeight: 618.0,
  );

  /// Región Johto - La tierra de leyendas
  static const RegionConfig johto = RegionConfig(
    name: 'Johto',
    description: 'The land of legends',
    icon: Icons.location_on,
    mapImagePath: 'assets/maps/images/johto.png',
    mapDataPath: 'assets/maps/johto_map.txt',
    originalWidth: 166.0,
    originalHeight: 144.0,
  );

  /// Región Hoenn - La tierra del mar y el cielo
  static const RegionConfig hoenn = RegionConfig(
    name: 'Hoenn',
    description: 'The land of sea and sky',
    icon: Icons.location_on,
    mapImagePath: 'assets/maps/images/hoenn.png',
    mapDataPath: 'assets/maps/hoenn_map.txt',
    originalWidth: 306.0,
    originalHeight: 221.0,
  );

  /// Región Sinnoh - La tierra del tiempo y el espacio
  static const RegionConfig sinnoh = RegionConfig(
    name: 'Sinnoh',
    description: 'The land of time and space',
    icon: Icons.location_on,
    mapImagePath: 'assets/maps/images/sinnoh.png',
    mapDataPath: 'assets/maps/sinnoh_map.txt',
    originalWidth: 216.0,
    originalHeight: 168.0,
  );

  /// Región Unova - La tierra de los sueños
  static const RegionConfig unova = RegionConfig(
    name: 'Unova',
    description: 'The land of dreams',
    icon: Icons.location_on,
    mapImagePath: 'assets/maps/images/unova.png',
    mapDataPath: 'assets/maps/unova_map.txt',
    originalWidth: 256.0,
    originalHeight: 168.0,
  );

  /// Región Kalos - La tierra de la belleza y los lazos
  static const RegionConfig kalos = RegionConfig(
    name: 'Kalos',
    description: 'The land of beauty and bonds',
    icon: Icons.location_on,
    mapImagePath: 'assets/maps/images/kalos.png',
    mapDataPath: 'assets/maps/kalos_map.txt',
    originalWidth: 315.0,
    originalHeight: 205.0,
  );

  /// Lista de todas las regiones disponibles
  static const List<RegionConfig> allRegions = [
    kanto,
    johto,
    hoenn,
    sinnoh,
    unova,
    kalos,
  ];

  /// Obtiene una región por su nombre
  /// 
  /// Retorna `null` si no se encuentra la región.
  static RegionConfig? fromName(String name) {
    try {
      return allRegions.firstWhere(
        (region) => region.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => 'RegionConfig($name, ${originalWidth}x$originalHeight)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegionConfig && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

import 'package:flutter/services.dart';
import '../../domain/entities/map_area.dart';

/// Parser de archivos HTML de mapas interactivos
/// 
/// Procesa archivos HTML con formato `<area>` tags (image maps) y los convierte
/// en objetos [MapArea] para la detección de colisiones.
/// 
/// Ejemplo de formato de entrada:
/// ```html
/// <area href="/location" shape="rect" coords="47,112,56,103" title="Pallet Town">
/// ```
class MapParser {
  /// Lee y parsea un archivo de mapa desde assets
  /// 
  /// [assetPath] debe ser la ruta completa al archivo .txt en assets
  /// (ej: 'assets/maps/kanto_map.txt')
  /// 
  /// Retorna una lista de [MapArea] encontradas en el archivo.
  /// Retorna lista vacía si hay error o no se encuentran áreas.
  static Future<List<MapArea>> parseMapFile(String assetPath) async {
    try {
      final String content = await rootBundle.loadString(assetPath);
      return _parseHTMLMap(content);
    } catch (e) {
      return [];
    }
  }

  /// Parsea el contenido HTML y extrae las áreas del mapa
  static List<MapArea> _parseHTMLMap(String htmlContent) {
    final List<MapArea> areas = [];

    // Expresión regular para encontrar tags <area>
    // Captura todo el contenido entre <area y >
    final areaRegex = RegExp(
      r'<area\s+([^>]+)>',
      caseSensitive: false,
      multiLine: true,
    );

    final matches = areaRegex.allMatches(htmlContent);

    for (final match in matches) {
      final areaTag = match.group(1);
      if (areaTag != null) {
        final area = _parseAreaTag(areaTag);
        if (area != null) {
          areas.add(area);
        }
      }
    }

    return areas;
  }

  /// Parsea un tag <area> individual y extrae sus atributos
  static MapArea? _parseAreaTag(String areaTag) {
    String? title;
    String? shape;
    String? coords;
    String? href;
    String? locationId;

    // Expresiones regulares para extraer atributos
    // Soporta comillas dobles y simples
    final hrefRegex = RegExp(r'''href=["']([^"']+)["']''');
    final shapeRegex = RegExp(r'''shape=["']([^"']+)["']''');
    final coordsRegex = RegExp(r'''coords=["']([^"']+)["']''');
    final titleRegex = RegExp(r'''title=["']([^"']+)["']''');
    final locationRegex = RegExp(r'''data-location=["']([^"']+)["']''');

    // Extraer valores
    final hrefMatch = hrefRegex.firstMatch(areaTag);
    final shapeMatch = shapeRegex.firstMatch(areaTag);
    final coordsMatch = coordsRegex.firstMatch(areaTag);
    final titleMatch = titleRegex.firstMatch(areaTag);
    final locationMatch = locationRegex.firstMatch(areaTag);

    if (hrefMatch != null) href = hrefMatch.group(1);
    if (shapeMatch != null) shape = shapeMatch.group(1);
    if (coordsMatch != null) coords = coordsMatch.group(1);
    if (titleMatch != null) title = titleMatch.group(1);
    if (locationMatch != null) locationId = locationMatch.group(1);

    // Validar que tenemos los datos mínimos necesarios
    if (title == null || shape == null || coords == null) {
      return null;
    }

    // Parsear las coordenadas (separadas por comas)
    final coordsList = coords
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .where((n) => n != null)
        .cast<int>()
        .toList();

    if (coordsList.isEmpty) {
      return null;
    }

    return MapArea(
      title: title,
      shape: shape,
      coords: coordsList,
      href: href,
      locationId: locationId,
    );
  }

  /// Encuentra el área que contiene un punto específico
  /// 
  /// [areas] lista de áreas a buscar
  /// [x] coordenada X del punto a verificar
  /// [y] coordenada Y del punto a verificar
  /// 
  /// Retorna la primera [MapArea] que contiene el punto, o `null` si ninguna
  /// área lo contiene.
  static MapArea? findAreaAtPoint(List<MapArea> areas, double x, double y) {
    for (final area in areas) {
      if (area.contains(x, y)) {
        return area;
      }
    }
    return null;
  }
}

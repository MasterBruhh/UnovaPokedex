/// Modelo que representa una zona interactiva del mapa
/// 
/// Corresponde a un área clickeable definida en los archivos HTML de mapa.
/// Soporta diferentes formas geométricas (rect, poly, circle).
class MapArea {
  /// Título descriptivo del área (ej: "Pallet Town", "Route 1")
  final String title;
  
  /// Forma geométrica del área: 'rect', 'poly', o 'circle'
  final String shape;
  
  /// Coordenadas que definen el área
  /// - rect: [x1, y1, x2, y2]
  /// - poly: [x1, y1, x2, y2, ..., xn, yn]
  /// - circle: [centerX, centerY, radius]
  final List<int> coords;
  
  /// URL de referencia opcional (heredado del formato HTML)
  final String? href;
  
  /// Identificador de la ubicación en PokeAPI (data-location)
  /// Usado para consultar información de Pokémon disponibles
  final String? locationId;

  const MapArea({
    required this.title,
    required this.shape,
    required this.coords,
    this.href,
    this.locationId,
  });

  /// Verifica si un punto (x, y) está dentro de esta área
  /// 
  /// Implementa algoritmos de detección de colisión para cada forma:
  /// - Rectángulos: comprobación de límites AABB
  /// - Polígonos: algoritmo de ray casting
  /// - Círculos: distancia euclidiana
  bool contains(double x, double y) {
    switch (shape.toLowerCase()) {
      case 'rect':
        return _containsRect(x, y);
      case 'poly':
        return _containsPoly(x, y);
      case 'circle':
        return _containsCircle(x, y);
      default:
        return false;
    }
  }

  /// Comprueba si el punto está dentro de un rectángulo
  bool _containsRect(double x, double y) {
    if (coords.length < 4) return false;
    
    // Normalizar coordenadas para asegurar min < max
    final minX = coords[0] < coords[2] ? coords[0] : coords[2];
    final maxX = coords[0] > coords[2] ? coords[0] : coords[2];
    final minY = coords[1] < coords[3] ? coords[1] : coords[3];
    final maxY = coords[1] > coords[3] ? coords[1] : coords[3];

    return x >= minX && x <= maxX && y >= minY && y <= maxY;
  }

  /// Comprueba si el punto está dentro de un polígono usando ray casting
  bool _containsPoly(double x, double y) {
    if (coords.length < 6) return false; // Mínimo 3 puntos (6 coordenadas)
    
    bool inside = false;
    for (int i = 0, j = coords.length - 2; i < coords.length; j = i, i += 2) {
      final xi = coords[i].toDouble();
      final yi = coords[i + 1].toDouble();
      final xj = coords[j].toDouble();
      final yj = coords[j + 1].toDouble();

      final intersect = ((yi > y) != (yj > y)) &&
          (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  /// Comprueba si el punto está dentro de un círculo
  bool _containsCircle(double x, double y) {
    if (coords.length < 3) return false;
    
    final centerX = coords[0].toDouble();
    final centerY = coords[1].toDouble();
    final radius = coords[2].toDouble();
    
    final dx = x - centerX;
    final dy = y - centerY;
    final distanceSquared = dx * dx + dy * dy;
    
    return distanceSquared <= radius * radius;
  }

  @override
  String toString() {
    return 'MapArea(title: $title, shape: $shape, coords: $coords)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapArea &&
        other.title == title &&
        other.shape == shape &&
        _listEquals(other.coords, coords) &&
        other.href == href &&
        other.locationId == locationId;
  }

  @override
  int get hashCode {
    return Object.hash(
      title,
      shape,
      Object.hashAll(coords),
      href,
      locationId,
    );
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

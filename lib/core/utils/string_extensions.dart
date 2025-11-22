/// Métodos de extensión para manipulación de String
extension StringExtensions on String {
  /// Convierte el primer carácter a mayúscula
  /// Ejemplo: "pikachu" -> "Pikachu"
  String toTitleCase() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Convierte kebab-case o snake_case a Title Case con espacios
  /// Ejemplo: "special-attack" -> "Special Attack"
  String toDisplayName() {
    if (isEmpty) return this;
    final cleaned = replaceAll('-', ' ').replaceAll('_', ' ');
    return cleaned
        .split(' ')
        .map((word) => word.isEmpty ? word : word.toTitleCase())
        .join(' ');
  }

  /// Elimina saltos de línea y avances de página, útil para texto de API
  String cleanApiText() {
    return replaceAll('\n', ' ').replaceAll('\f', ' ').trim();
  }
}


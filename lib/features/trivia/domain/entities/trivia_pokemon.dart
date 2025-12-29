import '../../../../core/config/app_constants.dart';

/// Entidad que representa un Pokémon en el juego de trivia.
/// 
/// Esta entidad de dominio contiene solo la información esencial
/// necesaria para la mecánica del juego de trivia.
class TriviaPokemon {
  /// Identificador único del Pokémon (1-1025 para Gen 1-9)
  final int id;
  
  /// Nombre del Pokémon en minúsculas
  final String name;
  
  /// Descripción/texto flavor del Pokémon (opcional)
  final String? description;
  
  /// URL del sprite artwork oficial del Pokémon
  final String spriteUrl;

  const TriviaPokemon({
    required this.id,
    required this.name,
    this.description,
    String? spriteUrl,
  }) : spriteUrl = spriteUrl ?? '';

  /// Crea un Pokemon con URL de sprite auto-generada
  factory TriviaPokemon.withSpriteUrl({
    required int id,
    required String name,
    String? description,
  }) {
    return TriviaPokemon(
      id: id,
      name: name,
      description: description,
      spriteUrl: '${AppConstants.pokemonArtworkBaseUrl}/$id.png',
    );
  }

  /// Retorna el nombre formateado para mostrar (capitalizado)
  String get displayName {
    if (name.isEmpty) return '';
    return name[0].toUpperCase() + name.substring(1);
  }

  /// Retorna una descripción limpia sin caracteres especiales
  String get cleanDescription {
    if (description == null) return '';
    return description!
        .replaceAll('\n', ' ')
        .replaceAll('\f', ' ')
        .replaceAll('\r', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TriviaPokemon && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TriviaPokemon(id: $id, name: $name)';
}

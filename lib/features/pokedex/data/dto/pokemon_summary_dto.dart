import '../../domain/entities/pokemon.dart';
import '../../domain/entities/pokemon_type.dart';

/// Objeto de Transferencia de Datos para resumen del Pokémon
class PokemonSummaryDto {
  const PokemonSummaryDto({
    required this.id,
    required this.name,
    required this.types,
  });

  final int id;
  final String name;
  final List<PokemonType> types;

  /// Crea un DTO desde la respuesta JSON
  factory PokemonSummaryDto.fromJson(Map<String, dynamic> json) {
    final rawTypes = (json['pokemon_v2_pokemontypes'] as List? ?? [])
        .map((type) => type['pokemon_v2_type']?['name'] as String?)
        .whereType<String>()
        .map((name) => PokemonType.fromString(name))
        .toList();

    return PokemonSummaryDto(
      id: json['id'] as int,
      name: json['name'] as String,
      types: rawTypes,
    );
  }

  /// Convierte DTO a entidad de dominio
  Pokemon toDomain() {
    return Pokemon(
      id: id,
      name: name,
      types: types,
    );
  }
}

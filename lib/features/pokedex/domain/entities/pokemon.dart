import 'package:equatable/equatable.dart';
import 'pokemon_type.dart';

/// Entidad de dominio que representa un Pokémon en la lista
class Pokemon extends Equatable {
  const Pokemon({
    required this.id,
    required this.name,
    required this.types,
    this.spriteUrl,
    this.shinySpriteUrl,
  });

  final int id;
  final String name;
  final List<PokemonType> types;
  /// URL del sprite normal del Pokémon
  final String? spriteUrl;
  /// URL del sprite shiny del Pokémon
  final String? shinySpriteUrl;

  @override
  List<Object?> get props => [id, name, types, spriteUrl, shinySpriteUrl];

  @override
  String toString() => 'Pokemon(id: $id, name: $name, types: $types)';

  /// Crea una copia del Pokémon con los campos especificados actualizados
  Pokemon copyWith({
    int? id,
    String? name,
    List<PokemonType>? types,
    String? spriteUrl,
    String? shinySpriteUrl,
  }) {
    return Pokemon(
      id: id ?? this.id,
      name: name ?? this.name,
      types: types ?? this.types,
      spriteUrl: spriteUrl ?? this.spriteUrl,
      shinySpriteUrl: shinySpriteUrl ?? this.shinySpriteUrl,
    );
  }
}


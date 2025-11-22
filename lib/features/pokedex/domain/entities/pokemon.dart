import 'package:equatable/equatable.dart';
import 'pokemon_type.dart';

/// Entidad de dominio que representa un Pokémon en la lista
class Pokemon extends Equatable {
  const Pokemon({
    required this.id,
    required this.name,
    required this.types,
  });

  final int id;
  final String name;
  final List<PokemonType> types;

  @override
  List<Object?> get props => [id, name, types];

  @override
  String toString() => 'Pokemon(id: $id, name: $name, types: $types)';
}


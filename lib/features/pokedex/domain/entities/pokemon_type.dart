/// Enumeración de tipos de Pokémon
enum PokemonType {
  normal,
  fire,
  water,
  electric,
  grass,
  ice,
  fighting,
  poison,
  ground,
  flying,
  psychic,
  bug,
  rock,
  ghost,
  dragon,
  dark,
  steel,
  fairy;

  /// Convierte un nombre de string a enum PokemonType
  static PokemonType fromString(String name) {
    return PokemonType.values.firstWhere(
      (type) => type.name == name.toLowerCase(),
      orElse: () => PokemonType.normal,
    );
  }
}


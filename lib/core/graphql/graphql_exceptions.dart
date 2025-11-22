/// Excepciones personalizadas para operaciones GraphQL
class GraphQLException implements Exception {
  const GraphQLException(this.message);

  final String message;

  @override
  String toString() => 'GraphQLException: $message';
}

/// Excepción lanzada cuando no se encuentra un Pokémon
class PokemonNotFoundException extends GraphQLException {
  const PokemonNotFoundException([String? pokemonIdentifier])
      : super(
          pokemonIdentifier != null
              ? 'Pokemon "$pokemonIdentifier" not found'
              : 'Pokemon not found',
        );
}

/// Excepción lanzada cuando hay un error de red
class PokedexNetworkException extends GraphQLException {
  const PokedexNetworkException()
      : super('Network error. Please check your internet connection.');
}


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

/// Excepción lanzada cuando hay un timeout
class PokedexTimeoutException extends GraphQLException {
  const PokedexTimeoutException()
      : super('Request timed out. Please try again.');
}

/// Excepción lanzada cuando se excede el rate limit
class PokedexRateLimitException extends GraphQLException {
  const PokedexRateLimitException()
      : super('Too many requests. Please wait a moment and try again.');
}

/// Excepción lanzada cuando el servidor devuelve un error
class PokedexServerException extends GraphQLException {
  const PokedexServerException([String? details])
      : super(details ?? 'Server error. Please try again later.');
}

/// Excepción lanzada cuando los datos recibidos son inválidos
class PokedexDataException extends GraphQLException {
  const PokedexDataException([String? details])
      : super(details ?? 'Invalid data received from server.');
}


import 'pokemon_summary_dto.dart';

/// Respuesta paginada de la lista de Pokémon
class PokemonListResponse {
  const PokemonListResponse({
    required this.pokemons,
    required this.nextOffset,
    required this.hasMore,
  });

  /// Lista de Pokémon de esta página
  final List<PokemonSummaryDto> pokemons;
  
  /// Offset para la siguiente página (cursor), null si no hay más
  final int? nextOffset;
  
  /// Indica si hay más páginas disponibles
  final bool hasMore;
}

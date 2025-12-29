import 'package:equatable/equatable.dart';
import 'pokemon.dart';

/// Representa una página de resultados de Pokémon con información de paginación
class PokemonPage extends Equatable {
  const PokemonPage({
    required this.pokemons,
    required this.nextCursor,
    required this.hasMore,
    this.totalCount,
  });

  /// Lista de Pokémon en esta página
  final List<Pokemon> pokemons;
  
  /// Cursor para la siguiente página (offset), null si no hay más
  final int? nextCursor;
  
  /// Indica si hay más páginas disponibles
  final bool hasMore;
  
  /// Total de Pokémon (opcional, para mostrar progreso)
  final int? totalCount;

  @override
  List<Object?> get props => [pokemons, nextCursor, hasMore, totalCount];
}

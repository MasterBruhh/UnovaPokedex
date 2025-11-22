import 'package:flutter/material.dart';
import '../../../../../core/utils/string_extensions.dart';
import '../../../domain/entities/pokemon_detail.dart';

/// Tarjeta que muestra los movimientos del Pokémon aprendidos por nivel
class PokemonMovesCard extends StatelessWidget {
  const PokemonMovesCard({
    super.key,
    required this.moves,
  });

  final List<PokemonMove> moves;

  @override
  Widget build(BuildContext context) {
    if (moves.isEmpty) {
      return const Text(
        'No se encontraron movimientos por nivel.',
        style: TextStyle(color: Colors.white70),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: moves.length,
      separatorBuilder: (_, __) => const Divider(
        color: Colors.white12,
        height: 8,
      ),
      itemBuilder: (context, index) {
        final move = moves[index];
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: SizedBox(
            width: 56,
            child: Text(
              'Nv. ${move.level}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            move.name.toDisplayName(),
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}


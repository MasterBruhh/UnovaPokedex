import 'package:flutter/material.dart';
import '../../../../../core/utils/string_extensions.dart';
import '../../../domain/entities/pokemon_detail.dart';
import 'move_method_tab_bar.dart';

/// Widget que muestra los movimientos del Pokémon organizados por método de aprendizaje
class PokemonMovesSection extends StatefulWidget {
  const PokemonMovesSection({
    super.key,
    required this.pokemon,
  });

  final PokemonDetail pokemon;

  @override
  State<PokemonMovesSection> createState() => _PokemonMovesSectionState();
}

class _PokemonMovesSectionState extends State<PokemonMovesSection> {
  MoveLearnMethod _selectedMethod = MoveLearnMethod.levelUp;

  @override
  Widget build(BuildContext context) {
    final moveCounts = {
      MoveLearnMethod.levelUp: widget.pokemon.moves.length,
      MoveLearnMethod.tm: widget.pokemon.tmMoves.length,
      MoveLearnMethod.tutor: widget.pokemon.tutorMoves.length,
      MoveLearnMethod.egg: widget.pokemon.eggMoves.length,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Barra de pestañas de métodos
        MoveMethodTabBar(
          selectedMethod: _selectedMethod,
          onMethodSelected: (method) {
            setState(() {
              _selectedMethod = method;
            });
          },
          moveCounts: moveCounts,
        ),
        const SizedBox(height: 16),
        
        // Lista de movimientos según el método seleccionado
        _buildMovesList(),
      ],
    );
  }

  Widget _buildMovesList() {
    final List<PokemonMove> moves;
    final bool showLevel;
    final String emptyMessage;

    switch (_selectedMethod) {
      case MoveLearnMethod.levelUp:
        moves = widget.pokemon.moves;
        showLevel = true;
        emptyMessage = 'No se encontraron movimientos por nivel.';
        break;
      case MoveLearnMethod.tm:
        moves = widget.pokemon.tmMoves;
        showLevel = false;
        emptyMessage = 'No se encontraron movimientos por MT/MO.';
        break;
      case MoveLearnMethod.tutor:
        moves = widget.pokemon.tutorMoves;
        showLevel = false;
        emptyMessage = 'No se encontraron movimientos por tutor.';
        break;
      case MoveLearnMethod.egg:
        moves = widget.pokemon.eggMoves;
        showLevel = false;
        emptyMessage = 'No se encontraron movimientos por huevo.';
        break;
    }

    if (moves.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white38, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                emptyMessage,
                style: const TextStyle(
                  color: Colors.white54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
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
        return _MoveListTile(
          move: move,
          showLevel: showLevel,
        );
      },
    );
  }
}

class _MoveListTile extends StatelessWidget {
  const _MoveListTile({
    required this.move,
    required this.showLevel,
  });

  final PokemonMove move;
  final bool showLevel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: showLevel
          ? SizedBox(
              width: 56,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Nv.${move.level}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          : Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flash_on,
                color: Colors.white54,
                size: 16,
              ),
            ),
      title: Text(
        move.name.toDisplayName(),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

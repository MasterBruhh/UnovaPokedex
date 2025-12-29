import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Enumeración para las pestañas de movimientos
enum MoveLearnMethod {
  levelUp,
  tm,
  tutor,
  egg,
}

/// Extension para obtener el label de cada método de aprendizaje
extension MoveLearnMethodExtension on MoveLearnMethod {
  String get label {
    switch (this) {
      case MoveLearnMethod.levelUp:
        return 'Nivel';
      case MoveLearnMethod.tm:
        return 'MT/MO';
      case MoveLearnMethod.tutor:
        return 'Tutor';
      case MoveLearnMethod.egg:
        return 'Huevo';
    }
  }

  IconData get icon {
    switch (this) {
      case MoveLearnMethod.levelUp:
        return Icons.trending_up;
      case MoveLearnMethod.tm:
        return Icons.album;
      case MoveLearnMethod.tutor:
        return Icons.school;
      case MoveLearnMethod.egg:
        return Icons.egg_outlined;
    }
  }
}

/// Widget que muestra la barra de pestañas para filtrar movimientos por método de aprendizaje
class MoveMethodTabBar extends StatelessWidget {
  const MoveMethodTabBar({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
    required this.moveCounts,
  });

  final MoveLearnMethod selectedMethod;
  final ValueChanged<MoveLearnMethod> onMethodSelected;
  /// Cantidad de movimientos por cada método para mostrar badge
  final Map<MoveLearnMethod, int> moveCounts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: MoveLearnMethod.values.map((method) {
          final isSelected = method == selectedMethod;
          final count = moveCounts[method] ?? 0;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => onMethodSelected(method),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.cardOverlay : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          method.icon,
                          size: 14,
                          color: isSelected ? Colors.white : Colors.white60,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            method.label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white60,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Badge con cantidad
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.white.withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

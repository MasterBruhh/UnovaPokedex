import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Enumeración para las pestañas de detalle del Pokémon
enum DetailTab {
  descripcion,
  formas,
  combate,
}

/// Extension para obtener el label de cada pestaña
extension DetailTabExtension on DetailTab {
  String get label {
    switch (this) {
      case DetailTab.descripcion:
        return 'Descripción';
      case DetailTab.formas:
        return 'Formas';
      case DetailTab.combate:
        return 'Combate';
    }
  }

  IconData get icon {
    switch (this) {
      case DetailTab.descripcion:
        return Icons.description_outlined;
      case DetailTab.formas:
        return Icons.transform;
      case DetailTab.combate:
        return Icons.sports_mma;
    }
  }
}

/// Widget que muestra la barra de pestañas para navegar entre secciones
class DetailTabBar extends StatelessWidget {
  const DetailTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final DetailTab selectedTab;
  final ValueChanged<DetailTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: DetailTab.values.map((tab) {
          final isSelected = tab == selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.cardOverlay : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab.icon,
                      size: 18,
                      color: isSelected ? Colors.white : Colors.white60,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tab.label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
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

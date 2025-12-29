import 'package:flutter/material.dart';

/// Un tile especial para la entrada del Pokédex en el menú principal
class PokedexTile extends StatelessWidget {
  const PokedexTile({
    super.key,
    required this.height,
    required this.onTap,
  });

  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Tab de carpeta - sobresale arriba
          Positioned(
            top: -8,
            left: 12,
            child: Container(
              width: 120,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                border: Border.all(
                  color: Colors.black.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
          ),
          // Cuerpo principal de la carpeta
          Container(
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.black.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.catching_pokemon,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'POKÉDEX',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


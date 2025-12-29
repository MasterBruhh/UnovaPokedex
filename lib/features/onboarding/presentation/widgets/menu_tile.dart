import 'package:flutter/material.dart';

/// Un widget de tile de menú personalizable para el menú principal
class MenuTile extends StatelessWidget {
  const MenuTile._({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.color,
    this.height,
    this.size,
    this.expand = false,
    this.child,
    this.showHeader = true,
  });

  /// Crea un tile de menú expansible (el ancho llena el espacio disponible)
  factory MenuTile.expand({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    double height = 160,
    Widget? child,
    bool showHeader = true,
  }) =>
      MenuTile._(
        title: title,
        icon: icon,
        onTap: onTap,
        color: color,
        height: height,
        expand: true,
        child: child,
        showHeader: showHeader,
      );

  /// Crea un tile de menú de tamaño fijo
  factory MenuTile.fixed({
    required String title,
    required IconData icon,
    required Size size,
    required VoidCallback onTap,
    required Color color,
    Widget? child,
    bool showHeader = true,
  }) =>
      MenuTile._(
        title: title,
        icon: icon,
        onTap: onTap,
        color: color,
        size: size,
        child: child,
        showHeader: showHeader,
      );

  /// Crea un tile de menú con altura fija (el ancho se adapta a la columna)
  factory MenuTile.fixedHeight({
    required String title,
    required IconData icon,
    required double height,
    required VoidCallback onTap,
    required Color color,
    Widget? child,
    bool showHeader = true,
  }) =>
      MenuTile._(
        title: title,
        icon: icon,
        onTap: onTap,
        color: color,
        height: height,
        expand: true,
        child: child,
        showHeader: showHeader,
      );

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double? height;
  final Size? size;
  final bool expand;
  final Widget? child;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final content = InkWell(
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
              width: 100,
              height: 35,
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
              child: child ??
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 64,
                        color: color,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );

    if (expand) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: content,
      );
    }

    return SizedBox.fromSize(size: size, child: content);
  }
}


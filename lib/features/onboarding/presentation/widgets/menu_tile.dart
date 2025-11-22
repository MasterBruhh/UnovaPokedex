import 'package:flutter/material.dart';

/// Un widget de tile de menú personalizable para el menú principal
class MenuTile extends StatelessWidget {
  const MenuTile._({
    required this.title,
    required this.icon,
    required this.onTap,
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
    double height = 160,
    Widget? child,
    bool showHeader = true,
  }) =>
      MenuTile._(
        title: title,
        icon: icon,
        onTap: onTap,
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
    Widget? child,
    bool showHeader = true,
  }) =>
      MenuTile._(
        title: title,
        icon: icon,
        onTap: onTap,
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
    Widget? child,
    bool showHeader = true,
  }) =>
      MenuTile._(
        title: title,
        icon: icon,
        onTap: onTap,
        height: height,
        expand: true,
        child: child,
        showHeader: showHeader,
      );

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final double? height;
  final Size? size;
  final bool expand;
  final Widget? child;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final header = showHeader
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
            ],
          )
        : const SizedBox.shrink();

    final content = Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              Expanded(
                child: Center(
                  child: child ??
                      Icon(
                        icon,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ],
          ),
        ),
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


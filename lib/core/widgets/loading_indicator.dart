import 'package:flutter/material.dart';

/// Un indicador de carga centrado
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.color = Colors.white,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: color),
    );
  }
}


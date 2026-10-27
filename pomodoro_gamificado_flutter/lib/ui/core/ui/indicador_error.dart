import 'package:flutter/material.dart';

import '../themes/colores.dart';

/// Mensaje de error con botón para reintentar.
class IndicadorError extends StatelessWidget {
  const IndicadorError({super.key, required this.mensaje, required this.onReintentar});

  final String mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mensaje, style: const TextStyle(color: Colores.error)),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onReintentar, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../domain/models/mascota.dart';
import 'iconos_juego.dart';

/// Los 2 panes del diseño: llenos los disponibles, punteados los usados.
class FilaPanes extends StatelessWidget {
  const FilaPanes({super.key, required this.disponibles, this.size = 34, this.colorVacio = const Color(0xFFC9B49A)});

  final int disponibles;
  final double size;
  final Color colorVacio;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$disponibles de ${Mascota.maxPanes} protectores disponibles',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < Mascota.maxPanes; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            IconoPan(size: size, vacio: i >= disponibles, colorVacio: colorVacio),
          ],
        ],
      ),
    );
  }
}

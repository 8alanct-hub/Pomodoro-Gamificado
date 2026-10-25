import 'package:flutter/material.dart';

import '../themes/colores.dart';
import 'iconos_juego.dart';

/// Pastilla con ícono y texto del diseño (racha, panes, conchas, estados).
class ChipContador extends StatelessWidget {
  const ChipContador({
    super.key,
    required this.icono,
    required this.texto,
    required this.fondo,
    required this.color,
    this.onTap,
    this.alto,
    this.tamanoTexto = 13,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  /// Racha: fuego naranja.
  factory ChipContador.racha(String texto, {double? alto, double tamanoTexto = 13, double iconoSize = 16}) => ChipContador(
    icono: Icon(Icons.local_fire_department_outlined, size: iconoSize, color: Colores.rachaTexto),
    texto: texto,
    fondo: Colores.rachaFondo,
    color: Colores.rachaTexto,
    alto: alto,
    tamanoTexto: tamanoTexto,
    padding: EdgeInsets.symmetric(horizontal: alto != null ? 12 : 10, vertical: 6),
  );

  /// Panes (protectores de racha).
  factory ChipContador.panes(String texto, {VoidCallback? onTap}) => ChipContador(
    icono: const IconoPan(),
    texto: texto,
    fondo: Colores.panFondo,
    color: Colores.panTexto,
    onTap: onTap,
  );

  /// Conchas para los minijuegos.
  factory ChipContador.conchas(String texto) => ChipContador(
    icono: const IconoConcha(),
    texto: texto,
    fondo: Colores.conchaFondo,
    color: Colores.conchaTexto,
  );

  final Widget icono;
  final String texto;
  final Color fondo;
  final Color color;
  final VoidCallback? onTap;
  final double? alto;
  final double tamanoTexto;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      height: alto,
      padding: padding,
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icono,
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(fontSize: tamanoTexto, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
    if (onTap == null) return chip;
    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: BorderRadius.circular(999), onTap: onTap, child: chip),
    );
  }
}

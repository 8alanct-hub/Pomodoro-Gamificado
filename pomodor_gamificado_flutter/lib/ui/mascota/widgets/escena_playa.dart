import 'package:flutter/material.dart';

/// Fondo de playa del diseño: cielo, sol, nubes, mar y arena.
/// [alturaArena] y [alturaMar] cambian entre la mascota y Pesca rápida.
class EscenaPlaya extends StatelessWidget {
  const EscenaPlaya({
    super.key,
    this.alturaArena = 84,
    this.alturaMar = 50,
    this.solArriba = 86,
    this.conDetalles = true,
  });

  final double alturaArena;
  final double alturaMar;
  final double solArriba;
  final bool conDetalles;

  Widget _nube(double w, double h, double opacidad) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: opacidad),
      borderRadius: BorderRadius.circular(999),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        const ColoredBox(color: Color(0xFF5DB8EA)),
        Positioned(
          right: 22,
          top: solArriba,
          child: Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD45C),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x59FFD45C), spreadRadius: 10)],
            ),
          ),
        ),
        Positioned(left: 18, top: solArriba + 14, child: _nube(74, 22, .9)),
        Positioned(left: 38, top: solArriba + 2, child: _nube(36, 26, .9)),
        Positioned(right: 86, top: solArriba + 64, child: _nube(54, 16, .75)),
        // Mar con su línea de espuma.
        Positioned(left: 0, right: 0, bottom: alturaArena - 14, height: alturaMar, child: const ColoredBox(color: Color(0xFF1FA2C2))),
        Positioned(
          left: 0,
          right: 0,
          bottom: alturaArena - 14 + alturaMar - 16,
          height: 6,
          child: ColoredBox(color: const Color(0xFF7DD3E3).withValues(alpha: .7)),
        ),
        // Arena con borde curvo.
        Positioned(
          left: -20,
          right: -20,
          bottom: 0,
          height: alturaArena,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF6D58E),
              borderRadius: BorderRadius.vertical(top: Radius.elliptical(220, 22)),
            ),
          ),
        ),
        if (conDetalles) ...[
          Positioned(
            left: 0,
            right: 0,
            bottom: 44,
            child: Center(
              child: Container(
                width: 160,
                height: 18,
                decoration: BoxDecoration(color: const Color(0xFFE2BC6C), borderRadius: BorderRadius.circular(999)),
              ),
            ),
          ),
          Positioned(
            left: 30,
            bottom: 22,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(color: Color(0xFFF29A8A), shape: BoxShape.circle),
            ),
          ),
          Positioned(right: 40, bottom: 30, child: _nube(14, 8, .8)),
        ],
      ],
    );
  }
}

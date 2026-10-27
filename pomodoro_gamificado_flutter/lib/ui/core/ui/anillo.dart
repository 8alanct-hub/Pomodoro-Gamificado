import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Anillo de progreso del temporizador y del descanso, como en el diseño.
class Anillo extends StatelessWidget {
  const Anillo({
    super.key,
    required this.progreso,
    required this.size,
    required this.grosor,
    required this.color,
    required this.fondo,
    required this.child,
  });

  /// De 0 a 1: cuánto del anillo está pintado.
  final double progreso;
  final double size;
  final double grosor;
  final Color color;
  final Color fondo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _AnilloPainter(progreso.clamp(0, 1).toDouble(), grosor, color, fondo),
        child: Center(child: child),
      ),
    );
  }
}

class _AnilloPainter extends CustomPainter {
  _AnilloPainter(this.progreso, this.grosor, this.color, this.fondo);
  final double progreso, grosor;
  final Color color, fondo;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(grosor / 2);
    final base = Paint()
      ..color = fondo
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor;
    canvas.drawArc(r, 0, math.pi * 2, false, base);
    if (progreso <= 0) return;
    canvas.drawArc(
      r,
      -math.pi / 2,
      math.pi * 2 * progreso,
      false,
      base
        ..color = color
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_AnilloPainter old) => old.progreso != progreso || old.color != color;
}

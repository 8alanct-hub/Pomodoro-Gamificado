import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Dibujos de la gamificación tomados del diseño (SVG pasados a Flutter):
/// pan, concha, huevo, peces, basura y el ícono de la mascota de la barra.

/// Pan (protector de racha). [vacio] dibuja solo el contorno punteado.
class IconoPan extends StatelessWidget {
  const IconoPan({super.key, this.size = 16, this.vacio = false, this.colorVacio = const Color(0xFFC9B49A)});
  final double size;
  final bool vacio;
  final Color colorVacio;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _PanPainter(vacio, colorVacio),
  );
}

/// Concha (ficha para los minijuegos). [conBase] agrega la base del diseño.
class IconoConcha extends StatelessWidget {
  const IconoConcha({super.key, this.size = 16, this.conBase = false});
  final double size;
  final bool conBase;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _ConchaPainter(conBase));
}

enum TipoObjeto { pez, dorado, lata, bota }

/// Objetos de Pesca rápida.
class IconoObjeto extends StatelessWidget {
  const IconoObjeto(this.tipo, {super.key, this.size = 34});
  final TipoObjeto tipo;
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _ObjetoPainter(tipo));
}

/// Huevo con signo de pregunta (tutorial, eclosión y mascota sin racha).
class IlustracionHuevo extends StatelessWidget {
  const IlustracionHuevo({super.key, this.ancho = 150, this.conPregunta = true});
  final double ancho;
  final bool conPregunta;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(ancho, ancho * 240 / 200),
    painter: _HuevoPainter(conPregunta),
  );
}

/// Ícono de la pestaña Mascota (cabeza y cuerpo del ave, en trazo).
class IconoMascotaNav extends StatelessWidget {
  const IconoMascotaNav({super.key, required this.color, this.size = 22});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _MascotaNavPainter(color));
}

/// Escala el lienzo para dibujar en las coordenadas del viewBox del SVG.
abstract class _ViewBoxPainter extends CustomPainter {
  _ViewBoxPainter(this.vw, this.vh);
  final double vw, vh;

  void dibujar(Canvas canvas);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / vw, size.height / vh);
    dibujar(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Trazo punteado (stroke-dasharray) para un [path].
Path _punteado(Path path, double trazo, double espacio) {
  final out = Path();
  for (final ui.PathMetric m in path.computeMetrics()) {
    var d = 0.0;
    while (d < m.length) {
      out.addPath(m.extractPath(d, d + trazo), Offset.zero);
      d += trazo + espacio;
    }
  }
  return out;
}

class _PanPainter extends _ViewBoxPainter {
  _PanPainter(this.vacio, this.colorVacio) : super(24, 24);
  final bool vacio;
  final Color colorVacio;

  @override
  void dibujar(Canvas canvas) {
    final corteza = Path()
      ..moveTo(4, 10)
      ..cubicTo(4, 5, 8, 3, 12, 3)
      ..cubicTo(16, 3, 20, 5, 20, 10)
      ..cubicTo(20, 12, 18.5, 12.5, 18, 13)
      ..lineTo(18, 20)
      ..cubicTo(18, 21, 17.5, 21.5, 16.5, 21.5)
      ..lineTo(7.5, 21.5)
      ..cubicTo(6.5, 21.5, 6, 21, 6, 20)
      ..lineTo(6, 13)
      ..cubicTo(5.5, 12.5, 4, 12, 4, 10)
      ..close();
    if (vacio) {
      canvas.drawPath(
        _punteado(corteza, 2, 2),
        Paint()
          ..color = colorVacio
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      return;
    }
    final miga = Path()
      ..moveTo(6.4, 10)
      ..cubicTo(6.4, 6.6, 9, 5.1, 12, 5.1)
      ..cubicTo(15, 5.1, 17.6, 6.6, 17.6, 10)
      ..cubicTo(17.6, 11.1, 16.6, 11.6, 16, 12.2)
      ..lineTo(16, 19.4)
      ..lineTo(8, 19.4)
      ..lineTo(8, 12.2)
      ..cubicTo(7.4, 11.6, 6.4, 11.1, 6.4, 10)
      ..close();
    canvas.drawPath(corteza, Paint()..color = const Color(0xFFD8914A));
    canvas.drawPath(miga, Paint()..color = const Color(0xFFF7DDB0));
  }
}

class _ConchaPainter extends _ViewBoxPainter {
  _ConchaPainter(this.conBase) : super(24, 24);
  final bool conBase;

  @override
  void dibujar(Canvas canvas) {
    final forma = Path()
      ..moveTo(12, 21)
      ..lineTo(4, 11.5)
      ..cubicTo(3.4, 7, 7, 3, 12, 3)
      ..cubicTo(17, 3, 20.6, 7, 20, 11.5)
      ..close();
    canvas.drawPath(forma, Paint()..color = const Color(0xFFF7B0A2));
    final linea = Paint()
      ..color = const Color(0xFFE07F72)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const base = Offset(12, 21);
    for (final p in const [
      Offset(7, 5.2),
      Offset(12, 3),
      Offset(17, 5.2),
      Offset(4.6, 8.6),
      Offset(19.4, 8.6),
    ]) {
      canvas.drawLine(base, p, linea);
    }
    if (conBase) {
      final pie = Path()
        ..moveTo(9.5, 19)
        ..lineTo(14.5, 19)
        ..lineTo(13.5, 21.5)
        ..lineTo(10.5, 21.5)
        ..close();
      canvas.drawPath(pie, Paint()..color = const Color(0xFFE07F72));
    }
  }
}

class _ObjetoPainter extends _ViewBoxPainter {
  _ObjetoPainter(this.tipo) : super(24, 24);
  final TipoObjeto tipo;

  void _pez(Canvas c, Color cola, Color cuerpo) {
    c.drawPath(
      Path()
        ..moveTo(7, 12)
        ..lineTo(2.5, 8)
        ..lineTo(2.5, 16)
        ..close(),
      Paint()..color = cola,
    );
    c.drawOval(Rect.fromCenter(center: const Offset(13.5, 12), width: 15, height: 9.6), Paint()..color = cuerpo);
    c.drawCircle(const Offset(17.5, 11), 1.1, Paint()..color = const Color(0xFF2D2A3E));
  }

  @override
  void dibujar(Canvas canvas) {
    switch (tipo) {
      case TipoObjeto.pez:
        _pez(canvas, const Color(0xFFE8853A), const Color(0xFFF09A45));
      case TipoObjeto.dorado:
        _pez(canvas, const Color(0xFFE0A800), const Color(0xFFFFC93C));
        canvas.drawPath(
          Path()
            ..moveTo(20, 3)
            ..lineTo(20.8, 4.7)
            ..lineTo(22.5, 5.5)
            ..lineTo(20.8, 6.3)
            ..lineTo(20, 8)
            ..lineTo(19.2, 6.3)
            ..lineTo(17.5, 5.5)
            ..lineTo(19.2, 4.7)
            ..close(),
          Paint()..color = Colors.white,
        );
      case TipoObjeto.lata:
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(6, 3, 12, 18), const Radius.circular(2)),
          Paint()..color = const Color(0xFFA7B0C2),
        );
        canvas.drawRect(const Rect.fromLTWH(6, 8, 12, 7), Paint()..color = const Color(0xFFD64545));
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(7.5, 3, 9, 1.6), const Radius.circular(.8)),
          Paint()..color = const Color(0xFF7C8598),
        );
      case TipoObjeto.bota:
        canvas.drawPath(
          Path()
            ..moveTo(7, 3)
            ..lineTo(14, 3)
            ..lineTo(14, 12)
            ..lineTo(19, 15)
            ..cubicTo(20.5, 15.9, 21, 17, 21, 18.5)
            ..lineTo(21, 19)
            ..lineTo(5, 19)
            ..lineTo(5, 3)
            ..close(),
          Paint()..color = const Color(0xFF7A5236),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(5, 19, 16, 2.5), const Radius.circular(1)),
          Paint()..color = const Color(0xFF4E3322),
        );
    }
  }
}

class _HuevoPainter extends _ViewBoxPainter {
  _HuevoPainter(this.conPregunta) : super(200, 240);
  final bool conPregunta;

  @override
  void dibujar(Canvas canvas) {
    final cascara = Path()
      ..moveTo(100, 10)
      ..cubicTo(150, 10, 185, 100, 185, 150)
      ..cubicTo(185, 200, 148, 232, 100, 232)
      ..cubicTo(52, 232, 15, 200, 15, 150)
      ..cubicTo(15, 100, 50, 10, 100, 10)
      ..close();
    final sombra = Path()
      ..moveTo(100, 10)
      ..cubicTo(150, 10, 185, 100, 185, 150)
      ..cubicTo(185, 200, 148, 232, 100, 232)
      ..cubicTo(140, 220, 165, 190, 165, 150)
      ..cubicTo(165, 100, 140, 30, 100, 10)
      ..close();
    canvas.drawPath(cascara, Paint()..color = const Color(0xFFFBF7EF));
    canvas.drawPath(sombra, Paint()..color = const Color(0xFFE7DCC9));
    final manchas = Paint()..color = const Color(0xFFC9D8F2);
    for (final (x, y, rx, ry) in const [
      (70.0, 110.0, 12.0, 9.0),
      (128.0, 168.0, 15.0, 11.0),
      (62.0, 186.0, 9.0, 7.0),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: rx * 2, height: ry * 2),
        manchas,
      );
    }
    if (!conPregunta) return;
    final texto = TextPainter(
      text: const TextSpan(
        text: '?',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 64,
          fontWeight: FontWeight.w800,
          color: Color(0xFFB9AE9B),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // En el SVG, y = 150 es la línea base del texto.
    texto.paint(
      canvas,
      Offset(100 - texto.width / 2, 150 - texto.computeDistanceToActualBaseline(TextBaseline.alphabetic)),
    );
  }
}

class _MascotaNavPainter extends _ViewBoxPainter {
  _MascotaNavPainter(this.color) : super(24, 24);
  final Color color;

  @override
  void dibujar(Canvas canvas) {
    final trazo = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawCircle(const Offset(9, 8), 4, trazo);
    canvas.drawPath(
      Path()
        ..moveTo(13, 8)
        ..lineTo(20, 8)
        ..lineTo(17, 11)
        ..lineTo(12.5, 11),
      trazo,
    );
    canvas.drawPath(
      Path()
        ..moveTo(6.5, 12)
        ..cubicTo(5, 15, 5, 18, 7, 20)
        ..lineTo(15, 20)
        ..cubicTo(17, 18, 17.2, 15, 15.5, 12.5),
      trazo,
    );
    canvas.drawCircle(const Offset(9.5, 7.5), .6, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _MascotaNavPainter old) => old.color != color;
}

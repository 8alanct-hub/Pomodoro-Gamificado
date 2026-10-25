import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../config/assets.dart';
import '../../core/themes/colores.dart';
import '../../core/ui/iconos_juego.dart';
import '../../mascota/widgets/escena_playa.dart';

/// Objeto que cae.
class _Objeto {
  _Objeto(this.tipo, this.x, this.y);
  final TipoObjeto tipo;
  final double x; // En unidades del diseño (0 a 390).
  double y;
}

/// Juego de Pesca rápida: la mascota se mueve abajo y atrapa lo que cae.
/// Se usan las mismas medidas del prototipo (ancho 390) y se escalan.
class JuegoPesca extends StatefulWidget {
  const JuegoPesca({
    super.key,
    required this.activo,
    required this.onPuntos,
    required this.onFin,
  });

  /// Si es `false`, el juego queda quieto (intro o fin).
  final bool activo;
  final ValueChanged<int> onPuntos;

  /// Se llama al atrapar basura: puntos totales, peces atrapados y motivo.
  final void Function(int peces, String motivo) onFin;

  @override
  State<JuegoPesca> createState() => _JuegoPescaState();
}

class _JuegoPescaState extends State<JuegoPesca> with SingleTickerProviderStateMixin {
  static const _ancho = 390.0;
  final _azar = math.Random();
  late final Ticker _ticker = createTicker(_paso);
  Duration _ultimo = Duration.zero;

  double _px = 195;
  int _dir = 0;
  double? _objetivo;
  final List<_Objeto> _objetos = [];
  double _t = 0;
  double _spawn = .6;
  int _peces = 0;
  double _alto = 700;

  @override
  void initState() {
    super.initState();
    if (widget.activo) _reiniciar();
  }

  @override
  void didUpdateWidget(JuegoPesca old) {
    super.didUpdateWidget(old);
    if (widget.activo && !old.activo) _reiniciar();
    if (!widget.activo && old.activo) _ticker.stop();
  }

  void _reiniciar() {
    _px = 195;
    _dir = 0;
    _objetivo = null;
    _objetos.clear();
    _t = 0;
    _spawn = .6;
    _peces = 0;
    _ultimo = Duration.zero;
    if (!_ticker.isActive) _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _paso(Duration ahora) {
    final dt = _ultimo == Duration.zero ? 0.016 : (ahora - _ultimo).inMicroseconds / 1e6;
    _ultimo = ahora;
    if (!widget.activo) return;
    _t += dt;
    final escalaY = _alto / 780; // Alto del área en el diseño.
    final vel = math.min(480.0, 150 + _t * 10) * escalaY;
    if (_dir != 0) {
      _px += _dir * 300 * dt;
    } else if (_objetivo != null) {
      final d = _objetivo! - _px;
      final m = 380 * dt;
      _px += d.abs() < m ? d : d.sign * m;
    }
    _px = _px.clamp(36, 354).toDouble();

    _spawn -= dt;
    if (_spawn <= 0) {
      final r = _azar.nextDouble();
      final tipo = r < .22
          ? (_azar.nextBool() ? TipoObjeto.lata : TipoObjeto.bota)
          : r < .30
          ? TipoObjeto.dorado
          : TipoObjeto.pez;
      _objetos.add(_Objeto(tipo, 24 + _azar.nextDouble() * 342, -36));
      _spawn = math.max(.42, 1.0 - _t * .018);
    }

    // Línea donde la mascota atrapa (pico a 180 px del fondo).
    final atrapeY = _alto - 180 * escalaY;
    var sumar = 0;
    String? fin;
    _objetos.removeWhere((o) {
      o.y += vel * dt;
      final cy = o.y + 17;
      if ((cy - atrapeY).abs() < 22 && (o.x - _px).abs() < 40) {
        switch (o.tipo) {
          case TipoObjeto.pez:
            sumar += 1;
            _peces++;
          case TipoObjeto.dorado:
            sumar += 5;
            _peces++;
          case TipoObjeto.lata:
            fin = 'Atrapaste una lata';
          case TipoObjeto.bota:
            fin = 'Atrapaste una bota vieja';
        }
        return true;
      }
      return o.y > _alto;
    });
    if (sumar > 0) widget.onPuntos(sumar);
    if (fin != null) {
      _ticker.stop();
      widget.onFin(_peces, fin!);
    }
    setState(() {});
  }

  void _apuntar(Offset local, double escalaX) {
    _dir = 0;
    _objetivo = local.dx / escalaX;
  }

  Widget _flecha(IconData icono, int dir, String etiqueta) {
    return Semantics(
      button: true,
      label: etiqueta,
      child: Listener(
        onPointerDown: (_) {
          _objetivo = null;
          _dir = dir;
        },
        onPointerUp: (_) => _dir = 0,
        onPointerCancel: (_) => _dir = 0,
        child: Container(
          width: 72,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .85),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icono, size: 28, color: Colores.primario),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        _alto = c.maxHeight;
        final escalaX = c.maxWidth / _ancho;
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Arrastrar o tocar el área mueve a la mascota hacia ese punto.
            Positioned.fill(
              child: GestureDetector(
                onPanDown: (d) => _apuntar(d.localPosition, escalaX),
                onPanUpdate: (d) => _apuntar(d.localPosition, escalaX),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    const Positioned.fill(
                      child: EscenaPlaya(alturaArena: 144, alturaMar: 60, solArriba: 40, conDetalles: false),
                    ),
                    for (final o in _objetos)
                      Positioned(
                        left: o.x * escalaX - 17,
                        top: o.y,
                        child: IconoObjeto(o.tipo),
                      ),
                    Positioned(
                      left: (_px - 30) * escalaX,
                      bottom: 92,
                      child: IgnorePointer(child: Image.asset(Assets.mascota, height: 110)),
                    ),
                  ],
                ),
              ),
            ),
            // Flechas encima: no pasan el toque al área de arrastre.
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _flecha(Icons.chevron_left, -1, 'Mover a la izquierda'),
                  _flecha(Icons.chevron_right, 1, 'Mover a la derecha'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/themes/colores.dart';
import '../../core/ui/comunes.dart';
import '../../core/ui/iconos_juego.dart';
import '../view_models/temporizador_viewmodel.dart';

/// Aviso al saltar, terminar o volver: muestra lo que sí y lo que no gana
/// (RF-005 CA-003). Devuelve `true` si confirma.
Future<bool> mostrarAvisoSalida(
  BuildContext context,
  TemporizadorViewModel vm,
  AccionFin accion,
) async {
  final terminar = accion == AccionFin.terminar;
  final confirmado = await mostrarHoja<bool>(
    context,
    builder: (context) => SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: CirculoIcono(
              size: 48,
              fondo: Color(0xFFFFF4E0),
              child: Icon(Icons.warning_amber_rounded, size: 24, color: Color(0xFFB26A00)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            terminar ? '¿Seguro que quieres terminar la sesión?' : '¿Seguro que quieres saltar este pomodoro?',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Llevas '),
                TextSpan(
                  text: '${vm.minutosCumplidos} min',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colores.texto),
                ),
                TextSpan(
                  text: ' de enfoque en ${vm.materiaNombre}. '
                      '${terminar ? 'Se cerrará la sesión y volverás al inicio.' : vm.esUltimo ? 'Es tu último pomodoro del ciclo: volverás al inicio.' : 'Pasarás directo al descanso.'}',
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, height: 20 / 14, color: Colores.textoSecundario),
          ),
          const SizedBox(height: 12),
          _Lista(
            titulo: 'Lo que sí ganas',
            colorTitulo: const Color(0xFF1E6B3E),
            fondo: const Color(0xFFEEF8F2),
            filas: vm.gana,
            si: true,
          ),
          const SizedBox(height: 12),
          _Lista(
            titulo: 'Lo que no ganas',
            colorTitulo: Colores.textoSecundario,
            fondo: Colores.superficie,
            filas: vm.pierde(accion),
            si: false,
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Seguir estudiando'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(terminar ? 'Terminar de todos modos' : 'Saltar de todos modos'),
          ),
        ],
      ),
    ),
  );
  return confirmado ?? false;
}

class _Lista extends StatelessWidget {
  const _Lista({
    required this.titulo,
    required this.colorTitulo,
    required this.fondo,
    required this.filas,
    required this.si,
  });

  final String titulo;
  final Color colorTitulo;
  final Color fondo;
  final List<FilaAviso> filas;
  final bool si;

  Widget _icono(IconoAviso i) => switch (i) {
    IconoAviso.reloj => const Icon(Icons.schedule, size: 18, color: Colores.primario),
    IconoAviso.racha => const Icon(Icons.local_fire_department_outlined, size: 18, color: Colores.rachaIcono),
    IconoAviso.concha => const IconoConcha(size: 20),
    IconoAviso.ciclo => const Icon(Icons.calendar_today_outlined, size: 18, color: Colores.textoSecundario),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: colorTitulo)),
          for (final f in filas)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  CirculoIcono(size: 30, fondo: Colores.blanco, child: _icono(f.icono)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f.texto,
                      style: TextStyle(
                        fontSize: 13,
                        height: 18 / 13,
                        color: si ? Colores.texto : Colores.textoSecundario,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  si
                      ? const Icon(Icons.check, size: 18, color: Colores.exito, semanticLabel: 'sí')
                      : const Icon(Icons.close, size: 18, color: Color(0xFFA32D2D), semanticLabel: 'no'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

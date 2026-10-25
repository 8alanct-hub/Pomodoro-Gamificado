import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';
import '../../../utils/formato.dart';
import '../../core/themes/colores.dart';
import '../../core/ui/anillo.dart';
import '../../core/ui/comunes.dart';
import '../view_models/descanso_viewmodel.dart';

/// Pantalla 08 · Descanso (azul claro).
class DescansoScreen extends StatefulWidget {
  const DescansoScreen({super.key, required this.viewModel});

  final DescansoViewModel viewModel;

  @override
  State<DescansoScreen> createState() => _DescansoScreenState();
}

class _DescansoScreenState extends State<DescansoScreen> {
  bool _avisoMostrado = false;

  DescansoViewModel get vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    vm.addListener(_alCambiar);
  }

  @override
  void dispose() {
    vm.removeListener(_alCambiar);
    vm.dispose();
    super.dispose();
  }

  /// Siguiente pomodoro, o el aviso de fin si ya se completó el ciclo.
  void _siguiente() {
    if (vm.finCiclo) {
      _mostrarFin();
    } else {
      context.go(Routes.temporizadorDe(vm.materiaId, pomodoro: vm.siguiente, completados: vm.completados));
    }
  }

  /// "¡Terminaste tus pomodoros!" y vuelta al inicio.
  void _mostrarFin() {
    _avisoMostrado = true;
    final fin = Formato.finDeCiclo(vm.completados, vm.config.pomodorosPorCiclo, vm.materiaNombre);
    mostrarHoja<void>(
      context,
      cerrable: false,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: CirculoIcono(
              size: 52,
              fondo: Color(0xFFE3F3EA),
              child: Icon(Icons.check, size: 26, color: Colores.exito),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            fin.titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Text(
            fin.texto,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, height: 22 / 15, color: Colores.textoSecundario),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colores.descanso),
            onPressed: () {
              Navigator.pop(context);
              this.context.go(Routes.inicio);
            },
            icon: const Icon(Icons.home_outlined, size: 20),
            label: const Text('Volver al inicio'),
          ),
        ],
      ),
    );
  }

  /// Al llegar a 00:00 aparece "¡Descanso terminado!".
  void _alCambiar() {
    if (!vm.terminado || _avisoMostrado) return;
    if (vm.finCiclo) return _mostrarFin();
    _avisoMostrado = true;
    mostrarHoja<void>(
      context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '¡Descanso terminado!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Text(
            'Es hora del pomodoro ${vm.siguiente} de ${vm.config.pomodorosPorCiclo} de ${vm.materiaNombre}.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, height: 22 / 15, color: Colores.textoSecundario),
          ),
          const SizedBox(height: 14),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colores.descanso),
            onPressed: () {
              Navigator.pop(context);
              _siguiente();
            },
            child: Text('Empezar pomodoro ${vm.siguiente} de ${vm.config.pomodorosPorCiclo}'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colores.descansoFondo,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: vm,
          builder: (context, _) => LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight - 56),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCEBFA),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.coffee_outlined, size: 18, color: Color(0xFF1F5C99)),
                            const SizedBox(width: 8),
                            Text(
                              vm.estadoTexto,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1F5C99)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        vm.titulo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Text(
                          vm.subtitulo,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, height: 22 / 15, color: Colores.textoSecundario),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Anillo(
                        progreso: vm.restante,
                        size: 240,
                        grosor: 14,
                        color: Colores.descansoAnillo,
                        fondo: const Color(0xFFDCEBFA),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              vm.textoTiempo,
                              style: const TextStyle(
                                fontSize: 54,
                                height: 58 / 54,
                                fontWeight: FontWeight.w800,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            const Text('de descanso', style: TextStyle(fontSize: 14, color: Colores.textoSecundario)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(
                        width: 300,
                        child: Text(
                          'Levántate, toma agua o mira lejos de la pantalla un momento.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, height: 18 / 13, color: Colores.textoSecundario),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Tarjeta(
                        borde: const Color(0xFFDCEBFA),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            const CirculoIcono(
                              child: Icon(Icons.local_fire_department_outlined, size: 20, color: Colores.primario),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vm.finCiclo ? 'Ciclo completo' : 'Luego viene',
                                    style: const TextStyle(fontSize: 12, color: Colores.textoSecundario),
                                  ),
                                  if (vm.finCiclo)
                                    Text(
                                      Formato.finDeCiclo(vm.completados, vm.config.pomodorosPorCiclo, vm.materiaNombre).texto,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                    )
                                  else
                                  Text(
                                    'Pomodoro ${vm.siguiente} de ${vm.config.pomodorosPorCiclo} · '
                                    '${vm.config.enfoqueMin} min de ${vm.materiaNombre}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: Colores.descanso),
                          onPressed: vm.terminado ? _siguiente : vm.alternar,
                          child: Text(
                            vm.terminado
                                ? (vm.finCiclo
                                      ? 'Volver al inicio'
                                      : 'Empezar pomodoro ${vm.siguiente} de ${vm.config.pomodorosPorCiclo}')
                                : vm.corriendo
                                ? 'Pausar descanso'
                                : 'Reanudar descanso',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colores.descanso,
                            side: const BorderSide(color: Colores.descanso, width: 1.5),
                          ),
                          onPressed: _siguiente,
                          icon: const Icon(Icons.skip_next_outlined, size: 20),
                          label: const Text('Saltar descanso'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

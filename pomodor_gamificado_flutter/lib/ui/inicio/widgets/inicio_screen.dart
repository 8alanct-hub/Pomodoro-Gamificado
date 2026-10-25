import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';
import '../../core/themes/colores.dart';
import '../../core/ui/chip_contador.dart';
import '../../core/ui/comunes.dart';
import '../../core/ui/indicador_error.dart';
import '../../core/ui/tarjeta_materia.dart';
import '../../../utils/formato.dart';
import '../view_models/inicio_viewmodel.dart';

/// Pantalla 03 · Inicio.
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key, required this.viewModel});

  final InicioViewModel viewModel;

  Future<void> _ir(BuildContext context, String ruta) async {
    await context.push(ruta);
    viewModel.cargar.execute(); // Actualiza al volver.
  }

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([vm, vm.cargar]),
          builder: (context, _) {
            if (vm.cargar.error) {
              return IndicadorError(
                mensaje: 'No se pudieron cargar tus datos.',
                onReintentar: vm.cargar.execute,
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
              children: [
                // Saludo, fecha, racha e iniciales.
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vm.nombre, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                          Text(vm.fecha, style: const TextStyle(fontSize: 13, color: Colores.textoSecundario)),
                        ],
                      ),
                    ),
                    ChipContador.racha(
                      Formato.plural(vm.mascota.rachaDias, 'día', 'días'),
                      alto: 36,
                      tamanoTexto: 14,
                      iconoSize: 18,
                    ),
                    const SizedBox(width: 8),
                    Semantics(
                      button: true,
                      label: 'Ver mi perfil',
                      child: GestureDetector(
                        onTap: () => _ir(context, Routes.perfil),
                        child: CirculoIcono(
                          size: 44,
                          child: Text(
                            vm.iniciales,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colores.primario),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _TarjetaMeta(viewModel: vm, onIniciar: () => _ir(context, Routes.nuevaSesion)),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text('Tus materias', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                    GestureDetector(
                      onTap: () => context.go(Routes.materias),
                      child: const Text(
                        'Ver todas',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colores.primario),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (vm.materias.isEmpty)
                  Tarjeta(
                    onTap: () => _ir(context, Routes.agregarMateria),
                    child: const Row(
                      children: [
                        CirculoIcono(radio: 12, child: Icon(Icons.add, color: Colores.primario)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Aún no tienes materias. Agrega tu primera materia con las horas del sílabo.',
                            style: TextStyle(fontSize: 13, color: Colores.textoSecundario),
                          ),
                        ),
                      ],
                    ),
                  ),
                for (final r in vm.materias.take(3)) ...[
                  TarjetaMateria(
                    nombre: r.materia.nombre,
                    detalle: r.detalle,
                    progreso: r.progreso,
                    onTap: () => _ir(context, Routes.nuevaSesionDe(r.materia.id)),
                  ),
                  const SizedBox(height: 12),
                ],
                if (vm.insignia != null) ...[
                  const SizedBox(height: 6),
                  Tarjeta(
                    fondo: const Color(0xFFFDF1D2),
                    borde: null,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    onTap: () => context.go(Routes.logros),
                    child: Row(
                      children: [
                        const CirculoIcono(
                          fondo: Colores.blanco,
                          child: Icon(Icons.emoji_events_outlined, size: 20, color: Colores.panTexto),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nueva insignia: ${vm.insignia!.nombre}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colores.panTexto),
                              ),
                              Text(
                                vm.insignia!.descripcion,
                                style: const TextStyle(fontSize: 12, color: Colores.panTexto),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colores.panTexto),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Tarjeta azul de la meta semanal con el botón "Iniciar pomodoro".
class _TarjetaMeta extends StatelessWidget {
  const _TarjetaMeta({required this.viewModel, required this.onIniciar});

  final InicioViewModel viewModel;
  final VoidCallback onIniciar;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    const claro = Color(0xFFE8EAF7);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colores.primario, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.track_changes, size: 18, color: claro),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Meta semanal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: claro)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colores.primarioOscuro, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  '${(vm.progresoSemana * 100).round()}%',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colores.blanco),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                Formato.horas(vm.horasSemana),
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colores.blanco),
              ),
              const SizedBox(width: 8),
              Text('de ${Formato.horas(vm.metaSemana)}', style: const TextStyle(fontSize: 15, color: claro)),
            ],
          ),
          const SizedBox(height: 12),
          BarraProgreso(
            valor: vm.progresoSemana,
            alto: 10,
            color: Colores.blanco,
            fondo: Colores.primarioOscuro,
          ),
          const SizedBox(height: 12),
          Text(vm.textoFalta, style: const TextStyle(fontSize: 13, color: claro)),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colores.blanco, foregroundColor: Colores.primario),
            onPressed: onIniciar,
            icon: const Icon(Icons.play_arrow_outlined, size: 22),
            label: const Text('Iniciar pomodoro'),
          ),
        ],
      ),
    );
  }
}

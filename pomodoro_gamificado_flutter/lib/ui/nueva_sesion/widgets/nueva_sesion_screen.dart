import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';
import '../../core/themes/colores.dart';
import '../../core/ui/comunes.dart';
import '../../core/ui/iconos_juego.dart';
import '../view_models/nueva_sesion_viewmodel.dart';

/// Pantalla 06 · Nueva sesión.
class NuevaSesionScreen extends StatefulWidget {
  const NuevaSesionScreen({super.key, required this.viewModel});

  final NuevaSesionViewModel viewModel;

  @override
  State<NuevaSesionScreen> createState() => _NuevaSesionScreenState();
}

class _NuevaSesionScreenState extends State<NuevaSesionScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.empezar.addListener(_alEmpezar);
  }

  @override
  void dispose() {
    widget.viewModel.empezar.removeListener(_alEmpezar);
    super.dispose();
  }

  void _alEmpezar() {
    final vm = widget.viewModel;
    if (!vm.empezar.completed) return;
    vm.empezar.clearResult();
    context.pushReplacement(Routes.temporizadorDe(vm.materiaId!, pomodoro: 1));
  }

  void _volver() => context.canPop() ? context.pop() : context.go(Routes.inicio);

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return Scaffold(
      appBar: Encabezado(titulo: 'Nueva sesión', onVolver: _volver),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) => LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight - 36),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Elige la materia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    if (vm.materias.isEmpty)
                      Tarjeta(
                        onTap: () => context.push(Routes.agregarMateria).then((_) => vm.cargar.execute()),
                        child: const Text(
                          'Aún no tienes materias. Toca aquí para agregar la primera.',
                          style: TextStyle(fontSize: 13, color: Colores.textoSecundario),
                        ),
                      ),
                    for (final r in vm.materias) ...[
                      _OpcionMateria(
                        nombre: r.materia.nombre,
                        detalle: r.restantes,
                        seleccionada: r.materia.id == vm.materiaId,
                        onTap: () => vm.seleccionarMateria(r.materia.id),
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 14),
                    const Text('Configura tu sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _Paso('Enfoque', '${vm.config.enfoqueMin} min', vm.cambiarEnfoque),
                    _Paso('Descanso corto', '${vm.config.descansoCortoMin} min', vm.cambiarDescansoCorto),
                    _Paso('Descanso largo', '${vm.config.descansoLargoMin} min', vm.cambiarDescansoLargo),
                    _Paso('Pomodoros por ciclo', '${vm.config.pomodorosPorCiclo}', vm.cambiarCiclo),
                    const SizedBox(height: 14),
                    _AvisoConchas(viewModel: vm),
                    const Spacer(),
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: vm.materiaId == null || vm.empezar.running ? null : vm.empezar.execute,
                      icon: const Icon(Icons.play_arrow_outlined, size: 22),
                      label: const Text('Comenzar sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Opción de materia con su círculo de selección.
class _OpcionMateria extends StatelessWidget {
  const _OpcionMateria({
    required this.nombre,
    required this.detalle,
    required this.seleccionada,
    required this.onTap,
  });

  final String nombre;
  final String detalle;
  final bool seleccionada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: seleccionada,
      button: true,
      child: Tarjeta(
        radio: 12,
        fondo: seleccionada ? Colores.indigoSuave : Colores.blanco,
        borde: seleccionada ? Colores.primario : Colores.borde,
        anchoBorde: seleccionada ? 2 : 1,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: seleccionada ? Colores.primario : const Color(0xFF8A8FB0), width: 2),
              ),
              child: seleccionada
                  ? const CircleAvatar(radius: 5, backgroundColor: Colores.primario)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(detalle, style: const TextStyle(fontSize: 12, color: Colores.textoSecundario)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila con − valor + sobre fondo gris claro.
class _Paso extends StatelessWidget {
  const _Paso(this.etiqueta, this.valor, this.cambiar);

  final String etiqueta;
  final String valor;
  final void Function(int) cambiar;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      decoration: BoxDecoration(color: Colores.superficie, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(child: Text(etiqueta, style: const TextStyle(fontSize: 15))),
          _BotonRedondo(
            icono: Icons.remove,
            tooltip: 'Disminuir $etiqueta',
            relleno: false,
            onTap: () => cambiar(-1),
          ),
          SizedBox(
            width: 60,
            child: Text(
              valor,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          _BotonRedondo(
            icono: Icons.add,
            tooltip: 'Aumentar $etiqueta',
            relleno: true,
            onTap: () => cambiar(1),
          ),
        ],
      ),
    );
  }
}

class _BotonRedondo extends StatelessWidget {
  const _BotonRedondo({required this.icono, required this.tooltip, required this.relleno, required this.onTap});

  final IconData icono;
  final String tooltip;
  final bool relleno;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: relleno ? Colores.primario : Colores.blanco,
        shape: CircleBorder(side: relleno ? BorderSide.none : const BorderSide(color: Colores.borde)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: 36,
            child: Icon(icono, size: 16, color: relleno ? Colores.blanco : Colores.primario),
          ),
        ),
      ),
    );
  }
}

/// Recuadro de conchas según la duración (RF-016).
class _AvisoConchas extends StatelessWidget {
  const _AvisoConchas({required this.viewModel});

  final NuevaSesionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final sin = viewModel.conchas == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: sin ? Colores.superficie : Colores.conchaFondo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: sin ? const Color(0xFFC9CDE0) : const Color(0xFFF7CFC6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IconoConcha(size: 30, conBase: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.conchaTitulo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: sin ? Colores.textoSecundario : Colores.conchaTexto,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  viewModel.conchaTexto,
                  style: const TextStyle(fontSize: 12, height: 17 / 12, color: Colores.textoSecundario),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

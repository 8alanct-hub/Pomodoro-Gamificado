import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/assets.dart';
import '../../../domain/models/mascota.dart';
import '../../../routing/routes.dart';
import '../../../utils/formato.dart';
import '../../core/themes/colores.dart';
import '../../core/ui/comunes.dart';
import '../../core/ui/iconos_juego.dart';
import '../../core/ui/nombre_mascota.dart';
import '../../core/ui/panes.dart';
import '../view_models/racha_viewmodel.dart';

/// Pantallas 11 (racha activa) y 12 (eclosión del huevo).
class RachaScreen extends StatefulWidget {
  const RachaScreen({super.key, required this.viewModel});

  final RachaViewModel viewModel;

  @override
  State<RachaScreen> createState() => _RachaScreenState();
}

class _RachaScreenState extends State<RachaScreen> {
  /// En la eclosión, "Ver mi racha" cambia a la vista de racha.
  bool _verRacha = false;

  RachaViewModel get vm => widget.viewModel;

  void _descanso() =>
      context.go(Routes.descansoDe(vm.materiaId, pomodoro: vm.pomodoro, completados: vm.completados));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: vm,
          builder: (context, _) {
            final eclosion = vm.esEclosion && !_verRacha;
            // En la eclosión no se puede seguir sin ponerle nombre.
            final bloqueado = eclosion && !vm.nombreListo;
            return LayoutBuilder(
              builder: (context, c) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: c.maxHeight - 52),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check, size: 18, color: Colores.exito),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                vm.resumen,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colores.exito),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (eclosion) _Eclosion(viewModel: vm) else _RachaActiva(viewModel: vm),
                        const SizedBox(height: 16),
                        _TarjetaPanes(mascota: vm.mascota, texto: vm.textoPanes),
                        const Spacer(),
                        const SizedBox(height: 16),
                        if (bloqueado)
                          const SizedBox.shrink()
                        else ...[
                        if (vm.finCiclo) ...[
                          // Resumen del ciclo antes de volver al inicio.
                          Text(
                            Formato.finDeCiclo(vm.completados, vm.pomodoro).texto,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: Colores.textoSecundario),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (vm.finCiclo)
                          FilledButton.icon(
                            onPressed: () => context.go(Routes.inicio),
                            icon: const Icon(Icons.home_outlined, size: 20),
                            label: const Text('Volver al inicio'),
                          )
                        else
                          FilledButton.icon(
                            onPressed: _descanso,
                            icon: const Icon(Icons.coffee_outlined, size: 20),
                            label: const Text('Continuar al descanso'),
                          ),
                        const SizedBox(height: 16),
                        // Sin "Ver a tu mascota": salir a la pestaña cortaba el ciclo
                        // de pomodoros. La mascota se visita desde la barra inferior.
                        if (eclosion)
                          TextButton(
                            onPressed: () => setState(() => _verRacha = true),
                            child: const Text('Ver mi racha'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Pantalla 11: mascota feliz, días de racha y la semana.
class _RachaActiva extends StatelessWidget {
  const _RachaActiva({required this.viewModel});

  final RachaViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    final m = vm.mascota;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 236,
            height: 236,
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: Color(0xFFEEF3FC), shape: BoxShape.circle),
            child: Image.asset(Assets.mascotaSaludando, height: 220, semanticLabel: 'Mascota Pomodoro 1 saludando'),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '¡${m.nombreVisible} está feliz!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Estudiaste hoy y tu racha sigue creciendo.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, height: 22 / 15, color: Colores.textoSecundario),
        ),
        const SizedBox(height: 16),
        Tarjeta(
          child: Column(
            children: [
              Row(
                children: [
                  const CirculoIcono(
                    size: 44,
                    fondo: Colores.rachaFondo,
                    child: Icon(Icons.local_fire_department_outlined, size: 24, color: Colores.rachaIcono),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${Formato.plural(m.rachaDias, 'día', 'días')} de racha',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Tu mejor racha: ${Formato.plural(m.mejorRacha, 'día', 'días')}',
                        style: const TextStyle(fontSize: 12, color: Colores.textoSecundario),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < 7; i++) _Dia(letra: Formato.inicialesDias[i], estado: vm.semana[i]),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dia extends StatelessWidget {
  const _Dia({required this.letra, required this.estado});

  final String letra;
  final DiaRacha estado;

  @override
  Widget build(BuildContext context) {
    final (BoxDecoration deco, Widget? hijo) = switch (estado) {
      DiaRacha.hoy => (
        BoxDecoration(
          color: Colores.primario,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colores.seleccion, spreadRadius: 3)],
        ),
        const Icon(Icons.check, size: 16, color: Colores.blanco),
      ),
      DiaRacha.hecho => (
        const BoxDecoration(color: Colores.indigoClaro, shape: BoxShape.circle),
        const Icon(Icons.check, size: 16, color: Colores.primario),
      ),
      DiaRacha.pan => (
        BoxDecoration(
          color: Colores.panFondo,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF2D3A8), width: 1.5),
        ),
        const IconoPan(size: 20),
      ),
      DiaRacha.futuro || DiaRacha.vacio => (
        BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFC9CDE0), width: 1.5)),
        null,
      ),
    };
    return Column(
      children: [
        Container(width: 34, height: 34, alignment: Alignment.center, decoration: deco, child: hijo),
        const SizedBox(height: 6),
        Text(
          letra,
          style: estado == DiaRacha.hoy
              ? const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colores.primario)
              : const TextStyle(fontSize: 12, color: Colores.textoSecundario),
        ),
      ],
    );
  }
}

/// Pantalla 12: el huevo se mueve y al tocarlo nace la mascota.
class _Eclosion extends StatefulWidget {
  const _Eclosion({required this.viewModel});

  final RachaViewModel viewModel;

  @override
  State<_Eclosion> createState() => _EclosionState();
}

class _EclosionState extends State<_Eclosion> with SingleTickerProviderStateMixin {
  late final AnimationController _meneo = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _meneo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final abierto = vm.huevoAbierto;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Material(
            color: const Color(0xFFEEF3FC),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: abierto ? null : vm.abrirHuevo,
              child: SizedBox.square(
                dimension: 260,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                  child: abierto
                      ? Align(
                          key: const ValueKey('mascota'),
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(Assets.mascotaSaludando, height: 240),
                        )
                      : Center(
                          key: const ValueKey('huevo'),
                          child: RotationTransition(
                            turns: Tween(begin: -0.015, end: 0.015).animate(_meneo),
                            child: Semantics(
                              button: true,
                              label: 'Abrir el huevo',
                              child: const IlustracionHuevo(ancho: 150),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          !abierto
              ? '¡Tu huevo se está moviendo!'
              : vm.nombreListo
              ? '¡Nació ${vm.mascota.nombreVisible}!'
              : '¡Nació tu mascota!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          !abierto
              ? 'Completaste tu primer pomodoro y empezaste una racha. Toca el huevo para conocer a tu mascota.'
              : vm.nombreListo
              ? 'Llevas 1 día de racha. Estudia mañana para que ${vm.mascota.nombreVisible} siga feliz.'
              : 'Antes de seguir, ponle un nombre.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, height: 22 / 15, color: Colores.textoSecundario),
        ),
        if (abierto && !vm.nombreListo) ...[
          const SizedBox(height: 16),
          FormularioNombreMascota(guardar: vm.guardarNombre, sugerido: vm.mascota.nombre),
        ],
      ],
    );
  }
}

/// Recuadro de protectores de racha.
class _TarjetaPanes extends StatelessWidget {
  const _TarjetaPanes({required this.mascota, required this.texto});

  final Mascota mascota;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colores.panFondo, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          FilaPanes(disponibles: mascota.panes),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Protectores de racha · ${mascota.panes} de ${Mascota.maxPanes}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colores.panTexto),
                ),
                Text(texto, style: const TextStyle(fontSize: 12, height: 16 / 12, color: Colores.panTexto)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

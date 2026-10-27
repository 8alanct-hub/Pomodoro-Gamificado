import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';
import '../../../utils/formato.dart';
import '../../../utils/result.dart';
import '../../core/themes/colores.dart';
import '../../core/ui/anillo.dart';
import '../../core/ui/comunes.dart';
import '../../core/ui/mensajes.dart';
import '../view_models/temporizador_viewmodel.dart';
import 'aviso_salida.dart';

/// Pantalla 07 · Temporizador.
class TemporizadorScreen extends StatefulWidget {
  const TemporizadorScreen({super.key, required this.viewModel});

  final TemporizadorViewModel viewModel;

  @override
  State<TemporizadorScreen> createState() => _TemporizadorScreenState();
}

class _TemporizadorScreenState extends State<TemporizadorScreen> {
  TemporizadorViewModel get vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    vm.cargar.addListener(_alCargar);
    vm.finalizar.addListener(_alFinalizar);
  }

  @override
  void dispose() {
    vm.cargar.removeListener(_alCargar);
    vm.finalizar.removeListener(_alFinalizar);
    vm.dispose();
    super.dispose();
  }

  /// Navegación después de cerrar la sesión (flujo de las pantallas 7 y 8).
  /// La pantalla de la mascota solo aparece con el primer bloque de 25 min
  /// del día, cuando la racha de hoy todavía no se había cumplido.
  /// Si el servidor no pudo iniciar la sesión, vuelve al inicio con el aviso.
  void _alCargar() {
    if (!vm.cargar.error) return;
    _avisarYSalir('No se pudo iniciar el pomodoro: ${mensajeDeError(vm.cargar.result)}');
  }

  void _avisarYSalir(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
    context.go(Routes.inicio);
  }

  void _alFinalizar() {
    final r = vm.finalizar.result;
    if (r is Error<ResumenSesion>) {
      _avisarYSalir('No se pudo guardar la sesión: ${mensajeDeError(r)}');
      return;
    }
    if (r is! Ok<ResumenSesion>) return;
    final resumen = r.value;
    final completados = vm.completadosCon(resumen.accion);
    if (resumen.accion == AccionFin.completar) {
      _mostrarCompletado(resumen);
    } else if (resumen.rachaNueva) {
      context.go(_rutaRacha(completados));
    } else if (resumen.accion == AccionFin.saltar && vm.esUltimo) {
      // Saltó el último pomodoro: cierra el ciclo con su resumen.
      _mostrarFinDeCiclo(completados);
    } else if (resumen.accion == AccionFin.saltar) {
      // Si ya tenía 25 min, la sesión sí contó: descanso normal.
      context.go(Routes.descansoDe(
        vm.materiaId,
        pomodoro: vm.pomodoro,
        saltado: resumen.conchas == 0,
        completados: completados,
      ));
    } else {
      context.go(Routes.inicio);
    }
  }

  String _rutaRacha(int completados) =>
      Routes.rachaDe(vm.materiaId, pomodoro: vm.pomodoro, fin: vm.esUltimo, completados: completados);

  String _rutaDescanso(int completados) =>
      Routes.descansoDe(vm.materiaId, pomodoro: vm.pomodoro, completados: completados);

  /// Aviso de fin de ciclo con cuántos pomodoros se completaron.
  void _mostrarFinDeCiclo(int completados) {
    final fin = Formato.finDeCiclo(completados, vm.config.pomodorosPorCiclo, vm.materiaNombre);
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
              child: Icon(Icons.flag_outlined, size: 26, color: Colores.exito),
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

  void _mostrarCompletado(ResumenSesion r) {
    final completados = vm.completadosCon(r.accion);
    final fin = Formato.finDeCiclo(completados, vm.config.pomodorosPorCiclo, vm.materiaNombre);
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
            vm.esUltimo ? fin.titulo : '¡Pomodoro completado!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Text(
            '${vm.esUltimo ? '${fin.texto} ' : ''}'
            'Sumaste ${r.minutos} min a ${vm.materiaNombre} y ganaste '
            '${Formato.plural(r.conchas, 'concha', 'conchas')} para jugar con tu mascota.'
            '${r.rachaNueva ? ' Tu mascota quiere verte.' : ''}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, height: 22 / 15, color: Colores.textoSecundario),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              this.context.go(
                r.rachaNueva
                    ? _rutaRacha(completados)
                    : vm.esUltimo
                    ? Routes.inicio
                    : _rutaDescanso(completados),
              );
            },
            child: Text(
              r.rachaNueva
                  ? 'Ver mi mascota'
                  : vm.esUltimo
                  ? 'Volver al inicio'
                  : 'Continuar al descanso',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmar(AccionFin accion) async {
    if (vm.estado == EstadoTemporizador.terminado) return;
    final estabaCorriendo = vm.corriendo;
    vm.pausar(); // El tiempo no corre mientras el aviso está abierto.
    final ok = await mostrarAvisoSalida(context, vm, accion);
    if (ok) {
      vm.finalizar.execute(accion);
    } else if (estabaCorriendo) {
      vm.reanudar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmar(AccionFin.terminar);
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: ListenableBuilder(
            listenable: vm,
            builder: (context, _) => Encabezado(
              titulo: vm.materiaNombre,
              onVolver: () => _confirmar(AccionFin.terminar),
            ),
          ),
        ),
        body: ListenableBuilder(
          listenable: vm,
          builder: (context, _) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              children: [
                // Estado y número de pomodoro.
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colores.indigoClaro, borderRadius: BorderRadius.circular(999)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.psychology_outlined, size: 18, color: Colores.primario),
                      const SizedBox(width: 8),
                      Text(
                        '${vm.corriendo || vm.estado == EstadoTemporizador.listo ? 'Enfoque' : 'En pausa'} · '
                        'Pomodoro ${vm.pomodoro} de ${vm.config.pomodorosPorCiclo}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colores.primario),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Anillo(
                  progreso: vm.progreso,
                  size: 268,
                  grosor: 16,
                  color: Colores.primario,
                  fondo: Colores.indigoClaro,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        vm.textoTiempo,
                        style: const TextStyle(
                          fontSize: 60,
                          height: 64 / 60,
                          fontWeight: FontWeight.w800,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        'restantes de ${vm.textoTotal}',
                        style: const TextStyle(fontSize: 15, color: Colores.textoSecundario),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                _Puntos(actual: vm.pomodoro, total: vm.config.pomodorosPorCiclo),
                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BotonCircular(
                      etiqueta: 'Terminar',
                      icono: Icons.stop_outlined,
                      onTap: () => _confirmar(AccionFin.terminar),
                    ),
                    const SizedBox(width: 28),
                    _BotonCircular(
                      etiqueta: vm.corriendo ? 'Pausar' : 'Reanudar',
                      icono: vm.corriendo ? Icons.pause : Icons.play_arrow,
                      principal: true,
                      onTap: vm.alternar,
                    ),
                    const SizedBox(width: 28),
                    _BotonCircular(
                      etiqueta: 'Saltar',
                      icono: Icons.skip_next_outlined,
                      onTap: () => _confirmar(AccionFin.saltar),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: Colores.superficie, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const CirculoIcono(child: Icon(Icons.schedule, size: 20, color: Colores.primario)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vm.textoHoy, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            Text(vm.textoFalta, style: const TextStyle(fontSize: 12, color: Colores.textoSecundario)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Puntos del ciclo: los anteriores llenos, el actual ancho.
class _Puntos extends StatelessWidget {
  const _Puntos({required this.actual, required this.total});

  final int actual;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var k = 1; k <= total; k++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: k == actual ? 28 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: k <= actual ? Colores.primario : Colores.indigoClaro,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

/// Botón redondo con etiqueta debajo (Terminar, Pausar, Saltar).
class _BotonCircular extends StatelessWidget {
  const _BotonCircular({
    required this.etiqueta,
    required this.icono,
    required this.onTap,
    this.principal = false,
  });

  final String etiqueta;
  final IconData icono;
  final VoidCallback onTap;
  final bool principal;

  @override
  Widget build(BuildContext context) {
    final size = principal ? 80.0 : 58.0;
    return Column(
      children: [
        if (!principal) const SizedBox(height: 11),
        Material(
          color: principal ? Colores.primario : Colores.blanco,
          shape: CircleBorder(
            side: principal ? BorderSide.none : const BorderSide(color: Colores.borde, width: 1.5),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox.square(
              dimension: size,
              child: Icon(
                icono,
                size: principal ? 32 : 22,
                color: principal ? Colores.blanco : Colores.textoSecundario,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(etiqueta, style: const TextStyle(fontSize: 12, color: Colores.textoSecundario)),
      ],
    );
  }
}

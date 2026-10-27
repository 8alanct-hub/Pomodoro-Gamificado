import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/assets.dart';
import '../../../domain/models/mascota.dart';
import '../../../routing/routes.dart';
import '../../../utils/formato.dart';
import '../../core/themes/colores.dart';
import '../../core/ui/chip_contador.dart';
import '../../core/ui/comunes.dart';
import '../../core/ui/iconos_juego.dart';
import '../../core/ui/nombre_mascota.dart';
import '../../core/ui/panes.dart';
import '../view_models/mascota_viewmodel.dart';
import 'escena_playa.dart';
import 'selector_minijuegos.dart';

/// Pestaña Mascota: mascota virtual (11b) o el huevo (13).
class MascotaScreen extends StatelessWidget {
  const MascotaScreen({super.key, required this.viewModel});

  final MascotaViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => viewModel.mascota.esHuevo
          ? _Huevo(viewModel: viewModel)
          : viewModel.faltaNombre
          ? _PonerNombre(viewModel: viewModel)
          : _MascotaVirtual(viewModel: viewModel),
    );
  }
}

/// Pantalla 11b · Mascota virtual.
class _MascotaVirtual extends StatefulWidget {
  const _MascotaVirtual({required this.viewModel});

  final MascotaViewModel viewModel;

  @override
  State<_MascotaVirtual> createState() => _MascotaVirtualState();
}

class _MascotaVirtualState extends State<_MascotaVirtual> with SingleTickerProviderStateMixin {
  /// Meneo de la mascota y corazones al acariciar.
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  MascotaViewModel get vm => widget.viewModel;

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _acariciar() {
    vm.acariciar.execute();
    _anim.forward(from: 0);
  }

  Future<void> _jugar() async {
    if (vm.panesAbierto) vm.alternarPanes();
    await mostrarSelectorMinijuegos(context, vm.mascota);
    vm.cargar.execute(); // Actualiza conchas y felicidad al volver.
  }

  Future<void> _cambiarNombre() async {
    if (vm.panesAbierto) vm.alternarPanes();
    vm.guardarNombre.clearResult();
    await mostrarHoja<void>(
      context,
      builder: (hoja) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(hoja).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Cambiar nombre', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text(
              'Elige un nuevo nombre para tu mascota.',
              style: TextStyle(fontSize: 15, color: Colores.textoSecundario),
            ),
            const SizedBox(height: 16),
            FormularioNombreMascota(
              guardar: vm.guardarNombre,
              sugerido: vm.mascota.nombre,
              textoBoton: 'Guardar nombre',
              alGuardar: () => Navigator.of(hoja).pop(),
            ),
            TextButton(onPressed: () => Navigator.of(hoja).pop(), child: const Text('Cancelar')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = vm.mascota;
    return Scaffold(
      appBar: Encabezado(
        titulo: m.nombreVisible,
        onTitulo: _cambiarNombre,
        acciones: [
          ChipContador.racha('${m.rachaDias}'),
          const SizedBox(width: 8),
          ChipContador.panes('${m.panes}', onTap: vm.alternarPanes),
          const SizedBox(width: 8),
          ChipContador.conchas('${m.conchas}'),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            children: [
              SizedBox(
                height: 330,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      const Positioned.fill(child: EscenaPlaya()),
                      // Globo con el mensaje.
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 280),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colores.blanco,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [BoxShadow(color: Color(0x1414173A), blurRadius: 8, offset: Offset(0, 2))],
                            ),
                            child: Text(
                              vm.mensaje,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      // Mascota (se menea al acariciarla).
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 52,
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _anim,
                            builder: (context, child) {
                              final t = _anim.value;
                              final giro = t < .57 ? math.sin(t / .57 * math.pi * 3) * 0.12 * (1 - t / .57) : 0.0;
                              return Transform.rotate(angle: giro, alignment: Alignment.bottomCenter, child: child);
                            },
                            child: Image.asset(Assets.mascota, height: 210, semanticLabel: 'Mascota Pomodoro 1'),
                          ),
                        ),
                      ),
                      // Corazones que suben.
                      Positioned(
                        top: 110,
                        left: 0,
                        right: 0,
                        child: AnimatedBuilder(
                          animation: _anim,
                          builder: (context, _) {
                            final t = _anim.value;
                            if (t == 0 || t == 1) return const SizedBox.shrink();
                            return Transform.translate(
                              offset: Offset(0, -70 * t),
                              child: Opacity(
                                opacity: t < .2 ? t / .2 : 1 - (t - .2) / .8,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Icon(Icons.favorite, size: 22, color: Color(0xFFE2557A)),
                                    SizedBox(width: 14),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 14),
                                      child: Icon(Icons.favorite, size: 28, color: Color(0xFFE2557A)),
                                    ),
                                    SizedBox(width: 14),
                                    Icon(Icons.favorite, size: 20, color: Color(0xFFE2557A)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Tarjeta(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Felicidad', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        ),
                        Text(
                          '${m.animo} · ${m.felicidad}%',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colores.primario),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: m.felicidad / 100),
                      duration: const Duration(milliseconds: 400),
                      builder: (context, v, _) => BarraProgreso(valor: v, alto: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _Accion(
                      etiqueta: 'Acariciar',
                      icono: const Icon(Icons.favorite_border, size: 22, color: Color(0xFFD23E68)),
                      fondo: const Color(0xFFFCE8EE),
                      onTap: _acariciar,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Accion(
                      etiqueta: 'Jugar',
                      icono: const Icon(Icons.sports_baseball_outlined, size: 22, color: Colores.primario),
                      fondo: Colores.indigoClaro,
                      onTap: _jugar,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (vm.panesAbierto)
            Positioned(
              top: 14,
              right: 16,
              width: 270,
              child: _AvisoPanes(mascota: m, texto: vm.textoPanes, onCerrar: vm.alternarPanes),
            ),
        ],
      ),
    );
  }
}

class _Accion extends StatelessWidget {
  const _Accion({required this.etiqueta, required this.icono, required this.fondo, required this.onTap});

  final String etiqueta;
  final Widget icono;
  final Color fondo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tarjeta(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
      child: Column(
        children: [
          CirculoIcono(size: 44, fondo: fondo, child: icono),
          const SizedBox(height: 6),
          Text(etiqueta, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Aviso de los panes que se abre desde el chip.
class _AvisoPanes extends StatelessWidget {
  const _AvisoPanes({required this.mascota, required this.texto, required this.onCerrar});

  final Mascota mascota;
  final String texto;
  final VoidCallback onCerrar;

  @override
  Widget build(BuildContext context) {
    final p = mascota.panes;
    return Material(
      color: Colores.blanco,
      elevation: 8,
      shadowColor: const Color(0x2914173A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFF2D3A8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Te ${p == 1 ? 'queda' : 'quedan'} $p de ${Mascota.maxPanes} panes',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colores.panTexto),
                  ),
                ),
                CirculoIcono(
                  size: 32,
                  fondo: Colores.panFondo,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: 'Cerrar',
                    onPressed: onCerrar,
                    icon: const Icon(Icons.close, size: 16, color: Colores.panTexto),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FilaPanes(disponibles: p),
            const SizedBox(height: 10),
            Text(texto, style: const TextStyle(fontSize: 13, height: 18 / 13, color: Colores.textoSecundario)),
          ],
        ),
      ),
    );
  }
}

/// Si la mascota nació pero no tiene nombre (por ejemplo, se cerró la app
/// en la eclosión), se pide antes de mostrarla.
class _PonerNombre extends StatelessWidget {
  const _PonerNombre({required this.viewModel});

  final MascotaViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Encabezado(titulo: 'Tu mascota'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          Center(
            child: Container(
              width: 236,
              height: 236,
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(color: Color(0xFFEEF3FC), shape: BoxShape.circle),
              child: Image.asset(Assets.mascota, height: 210),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '¡Tu mascota necesita un nombre!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          FormularioNombreMascota(guardar: viewModel.guardarNombre, sugerido: viewModel.mascota.nombre),
        ],
      ),
    );
  }
}

/// Pantalla 13 · Sin racha: la mascota es un huevo.
class _Huevo extends StatelessWidget {
  const _Huevo({required this.viewModel});

  final MascotaViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final m = viewModel.mascota;
    final perdida = viewModel.rachaPerdida;
    return Scaffold(
      appBar: const Encabezado(titulo: 'Tu mascota'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          Center(
            child: Container(
              width: 236,
              height: 236,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Color(0xFFF2F3F7), shape: BoxShape.circle),
              child: IlustracionHuevo(ancho: 140, conPregunta: !perdida),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            perdida ? 'Tu racha se reinició' : '¿Qué hay dentro del huevo?',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            perdida
                ? 'Pasaron días sin estudiar y ya no quedaban panes. Tu mascota volvió a ser un huevo, '
                      'pero puede nacer de nuevo.'
                : 'Completa tu primer pomodoro de 25 minutos para empezar una racha y descubrirlo.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, height: 22 / 15, color: Colores.textoSecundario),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _Dato(titulo: 'Racha actual', valor: Formato.plural(m.rachaDias, 'día', 'días'))),
              const SizedBox(width: 12),
              Expanded(
                child: _Dato(
                  titulo: 'Tu mejor racha',
                  valor: Formato.plural(m.mejorRacha, 'día', 'días'),
                  color: Colores.primario,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Tarjeta(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                FilaPanes(disponibles: perdida ? 0 : m.panes, colorVacio: const Color(0xFFB9BDD0)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Protectores de racha · ${perdida ? 0 : m.panes} de ${Mascota.maxPanes}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        perdida
                            ? 'Cuando tu mascota vuelva a nacer, recuperas tus 2 panes.'
                            : 'Si un día no estudias, un pan protege tu racha.',
                        style: const TextStyle(fontSize: 12, height: 16 / 12, color: Colores.textoSecundario),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push(Routes.nuevaSesion),
            icon: const Icon(Icons.play_arrow_outlined, size: 22),
            label: const Text('Completa un pomodoro para que nazca'),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: () => context.go(Routes.inicio), child: const Text('Ir al inicio')),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.titulo, required this.valor, this.color = Colores.texto});

  final String titulo;
  final String valor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colores.superficie, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontSize: 12, color: Colores.textoSecundario)),
          const SizedBox(height: 2),
          Text(valor, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

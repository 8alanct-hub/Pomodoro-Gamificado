import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';
import '../../../utils/formato.dart';
import '../../core/themes/colores.dart';
import '../../core/ui/chip_contador.dart';
import '../../core/ui/iconos_juego.dart';
import '../view_models/pesca_rapida_viewmodel.dart';
import 'juego_pesca.dart';

/// Pantalla 14 · Pesca rápida.
class PescaRapidaScreen extends StatelessWidget {
  const PescaRapidaScreen({super.key, required this.viewModel});

  final PescaRapidaViewModel viewModel;

  void _salir(BuildContext context) => context.canPop() ? context.pop() : context.go(Routes.mascota);

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: vm,
          builder: (context, _) => Column(
            children: [
              // Encabezado: salir, título, puntos y conchas.
              SizedBox(
                height: 64,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Salir del juego',
                        onPressed: () => _salir(context),
                        icon: const Icon(Icons.close, color: Colores.texto),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('Pesca rápida', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      ),
                      ChipContador(
                        icono: const IconoObjeto(TipoObjeto.pez, size: 18),
                        texto: '${vm.puntos}',
                        fondo: Colores.indigoClaro,
                        color: Colores.primario,
                        tamanoTexto: 15,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      const SizedBox(width: 8),
                      ChipContador.conchas('${vm.conchas}'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: JuegoPesca(
                        key: ValueKey(vm.partida),
                        activo: vm.fase == FasePesca.jugando,
                        onPuntos: vm.sumar,
                        onFin: (peces, motivo) =>
                            vm.terminar.execute((puntos: vm.puntos, peces: peces, motivo: motivo)),
                      ),
                    ),
                    if (vm.fase == FasePesca.intro)
                      _Capa(oscuridad: .35, child: _Intro(viewModel: vm)),
                    if (vm.fase == FasePesca.fin)
                      _Capa(oscuridad: .45, child: _Fin(viewModel: vm, onSalir: () => _salir(context))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fondo oscuro con una tarjeta centrada.
class _Capa extends StatelessWidget {
  const _Capa({required this.oscuridad, required this.child});

  final double oscuridad;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colores.texto.withValues(alpha: oscuridad),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colores.blanco, borderRadius: BorderRadius.circular(28)),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// "¿Cómo se juega?".
class _Intro extends StatelessWidget {
  const _Intro({required this.viewModel});

  final PescaRapidaViewModel viewModel;

  Widget _regla(Widget icono, String texto, String valor, Color fondo, Color colorValor) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(14)),
    child: Row(
      children: [
        icono,
        const SizedBox(width: 12),
        Expanded(child: Text(texto, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
        Text(valor, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: colorValor)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '¿Cómo se juega?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        const Text(
          'Arrastra a tu mascota o usa las flechas para atrapar lo que cae.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, height: 20 / 14, color: Colores.textoSecundario),
        ),
        const SizedBox(height: 14),
        _regla(const IconoObjeto(TipoObjeto.pez, size: 30), 'Pez', '+1', Colores.indigoSuave, Colores.exito),
        _regla(const IconoObjeto(TipoObjeto.dorado, size: 30), 'Pez dorado', '+5', const Color(0xFFFFF8E1), Colores.exito),
        _regla(
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [IconoObjeto(TipoObjeto.lata, size: 24), SizedBox(width: 2), IconoObjeto(TipoObjeto.bota, size: 24)],
          ),
          'Basura',
          'Pierdes',
          const Color(0xFFFCEBEB),
          const Color(0xFFA32D2D),
        ),
        const SizedBox(height: 6),
        const Text(
          'Los peces que se escapan no restan. Cada vez caen más rápido.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, height: 17 / 12, color: Colores.textoSecundario),
        ),
        const SizedBox(height: 14),
        if (vm.tieneConchas)
          FilledButton(
            onPressed: vm.empezar.running ? null : vm.empezar.execute,
            child: const Text('Empezar · usa 1 concha'),
          )
        else ...[
          const Text(
            'No tienes conchas. Completa un pomodoro de 25 min para ganar una.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 18 / 13),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => context.go(Routes.nuevaSesion),
            child: const Text('Iniciar pomodoro'),
          ),
        ],
      ],
    );
  }
}

/// "¡Fin de la partida!".
class _Fin extends StatelessWidget {
  const _Fin({required this.viewModel, required this.onSalir});

  final PescaRapidaViewModel viewModel;
  final VoidCallback onSalir;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          vm.motivo,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFA32D2D)),
        ),
        const SizedBox(height: 12),
        const Text(
          '¡Fin de la partida!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${vm.puntos}',
              style: const TextStyle(fontSize: 52, height: 56 / 52, fontWeight: FontWeight.w800, color: Colores.primario),
            ),
            const SizedBox(width: 6),
            const Text('puntos', style: TextStyle(fontSize: 16, color: Colores.textoSecundario)),
          ],
        ),
        if (vm.nuevoRecord) ...[
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFFFF4D6), borderRadius: BorderRadius.circular(999)),
              child: const Text(
                '¡Nuevo récord!',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colores.panTexto),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _Caja(
                titulo: 'Tu récord',
                valor: Formato.plural(vm.mascota.recordPesca, 'punto', 'puntos'),
                fondo: Colores.indigoSuave,
                color: Colores.texto,
                colorTitulo: Colores.textoSecundario,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Caja(
                titulo: 'Tu mascota',
                valor: '+${vm.felicidadGanada} felicidad',
                fondo: const Color(0xFFFCE8EE),
                color: const Color(0xFF8A2C47),
                colorTitulo: const Color(0xFF8A2C47),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Te ${vm.conchas == 1 ? 'queda' : 'quedan'} ${Formato.plural(vm.conchas, 'concha', 'conchas')}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Colores.textoSecundario),
        ),
        const SizedBox(height: 12),
        if (vm.tieneConchas)
          FilledButton(
            onPressed: vm.empezar.running ? null : vm.empezar.execute,
            child: const Text('Jugar otra vez · 1 concha'),
          )
        else
          FilledButton(
            onPressed: () => context.go(Routes.nuevaSesion),
            child: const Text('Gana conchas con un pomodoro'),
          ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onSalir, child: const Text('Volver con tu mascota')),
      ],
    );
  }
}

class _Caja extends StatelessWidget {
  const _Caja({
    required this.titulo,
    required this.valor,
    required this.fondo,
    required this.color,
    required this.colorTitulo,
  });

  final String titulo;
  final String valor;
  final Color fondo;
  final Color color;
  final Color colorTitulo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(fontSize: 12, color: colorTitulo)),
          const SizedBox(height: 2),
          Text(valor, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}


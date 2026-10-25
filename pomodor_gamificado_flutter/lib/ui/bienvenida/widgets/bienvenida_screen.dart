import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';
import '../../core/themes/colores.dart';
import '../../core/ui/iconos_juego.dart';
import '../view_models/bienvenida_viewmodel.dart';

/// Pantalla 02b · Bienvenida y tutorial.
class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key, required this.viewModel});

  final BienvenidaViewModel viewModel;

  void _salir(BuildContext context, String ruta) {
    viewModel.terminar();
    context.go(ruta);
  }

  @override
  Widget build(BuildContext context) {
    // El círculo mide 300 en el diseño; se reduce en pantallas bajas.
    final circulo = (MediaQuery.sizeOf(context).height * 0.36).clamp(200.0, 300.0);
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            final p = viewModel.paso;
            final paso = BienvenidaViewModel.pasos[p];
            return Column(
              children: [
                // Encabezado: "Paso n de 4" y "Saltar".
                SizedBox(
                  height: 56,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
                    child: Row(
                      children: [
                        Text(
                          'Paso ${p + 1} de ${BienvenidaViewModel.pasos.length}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colores.textoSecundario,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _salir(context, Routes.inicio),
                          child: const Text(
                            'Saltar',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                    child: Column(
                      children: [
                        Container(
                          width: circulo,
                          height: circulo,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEEF3FC),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: FittedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: switch (p) {
                                0 => const _IlustracionLogo(),
                                1 => const _IlustracionMateria(),
                                2 => const _IlustracionReloj(),
                                _ => const IlustracionHuevo(),
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          paso.titulo,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: Text(
                            paso.texto,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 22 / 15,
                              color: Colores.textoSecundario,
                            ),
                          ),
                        ),
                        if (viewModel.esUltimo) ...[
                          const SizedBox(height: 24),
                          const _ChipsGamificacion(),
                        ],
                        const Spacer(),
                        _Puntos(actual: p, total: BienvenidaViewModel.pasos.length, onTap: viewModel.irA),
                        const SizedBox(height: 24),
                        if (!viewModel.esUltimo)
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: viewModel.siguiente,
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Siguiente'),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 20),
                                ],
                              ),
                            ),
                          )
                        else ...[
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => _salir(context, Routes.agregarMateria),
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text('Agregar mi primera materia'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 44,
                            child: TextButton(
                              onPressed: () => _salir(context, Routes.inicio),
                              child: const Text(
                                'Ir al inicio',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Paso 1: reloj en círculo azul y la palabra "Pomodoro".
class _IlustracionLogo extends StatelessWidget {
  const _IlustracionLogo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 70,
          backgroundColor: Colores.primario,
          child: Icon(Icons.schedule, size: 76, color: Colores.blanco),
        ),
        SizedBox(height: 14),
        Text(
          'Pomodoro',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colores.primario),
        ),
      ],
    );
  }
}

/// Paso 2: tarjeta de materia con su barra y el cálculo de la meta.
class _IlustracionMateria extends StatelessWidget {
  const _IlustracionMateria();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colores.blanco,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colores.borde),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EAF7),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.menu_book_outlined, size: 16, color: Colores.primario),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Cálculo II', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                    const Text(
                      '6 h/sem',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colores.primario),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: const LinearProgressIndicator(
                    value: 0.58,
                    minHeight: 6,
                    color: Colores.primario,
                    backgroundColor: Color(0xFFE8EAF7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colores.primario,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.track_changes, size: 18, color: Colores.blanco),
                SizedBox(width: 8),
                Text(
                  '96 h ÷ 16 semanas = 6 h',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colores.blanco),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Paso 3: anillo del temporizador al 75 % con "25:00".
class _IlustracionReloj extends StatelessWidget {
  const _IlustracionReloj();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 190,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 0.75,
            strokeWidth: 14,
            strokeCap: StrokeCap.round,
            color: Colores.primario,
            backgroundColor: Color(0xFFD9DCF0),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('25:00', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800)),
              Text('enfoque', style: TextStyle(fontSize: 13, color: Colores.textoSecundario)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Paso 4: chips de racha, panes y conchas.
class _ChipsGamificacion extends StatelessWidget {
  const _ChipsGamificacion();

  Widget _chip(Widget icono, String texto, Color fondo, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(999)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icono,
        const SizedBox(width: 4),
        Text(texto, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _chip(
          const Icon(Icons.local_fire_department_outlined, size: 16, color: Color(0xFFB2581C)),
          'Racha',
          const Color(0xFFFFF0E0),
          const Color(0xFFB2581C),
        ),
        _chip(const IconoPan(), '2 panes', const Color(0xFFFFF7EC), const Color(0xFF6B4A00)),
        _chip(const IconoConcha(), 'Conchas', const Color(0xFFFFF3F0), const Color(0xFFA3402F)),
      ],
    );
  }
}

/// Indicador de pasos: el actual es más ancho y azul.
class _Puntos extends StatelessWidget {
  const _Puntos({required this.actual, required this.total, required this.onTap});

  final int actual;
  final int total;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Semantics(
              button: true,
              label: 'Ir al paso ${i + 1}',
              child: GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: i == actual ? 28 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: i == actual ? Colores.primario : const Color(0xFFD9DCF0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

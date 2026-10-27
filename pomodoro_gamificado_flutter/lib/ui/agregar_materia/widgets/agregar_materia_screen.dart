import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';
import '../../core/themes/colores.dart';
import '../../core/ui/campo_texto.dart';
import '../../core/ui/comunes.dart';
import '../view_models/agregar_materia_viewmodel.dart';

/// Pantalla 05 · Agregar materia.
class AgregarMateriaScreen extends StatefulWidget {
  const AgregarMateriaScreen({super.key, required this.viewModel});

  final AgregarMateriaViewModel viewModel;

  @override
  State<AgregarMateriaScreen> createState() => _AgregarMateriaScreenState();
}

class _AgregarMateriaScreenState extends State<AgregarMateriaScreen> {
  final _nombre = TextEditingController();
  final _horas = TextEditingController();
  final _semanas = TextEditingController(text: '16');

  @override
  void initState() {
    super.initState();
    widget.viewModel.guardar.addListener(_alGuardar);
  }

  @override
  void dispose() {
    widget.viewModel.guardar.removeListener(_alGuardar);
    _nombre.dispose();
    _horas.dispose();
    _semanas.dispose();
    super.dispose();
  }

  void _alGuardar() {
    if (widget.viewModel.guardar.completed) _salir();
  }

  void _salir() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.materias); // Viene del tutorial.
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return Scaffold(
      appBar: Encabezado(titulo: 'Agregar materia', onVolver: _salir),
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
                    const Text(
                      'Con los datos del sílabo calculamos cuántas horas debes estudiar cada semana.',
                      style: TextStyle(fontSize: 15, height: 22 / 15, color: Colores.textoSecundario),
                    ),
                    const SizedBox(height: 16),
                    CampoTexto(
                      etiqueta: 'Nombre de la materia',
                      icono: Icons.menu_book_outlined,
                      colorIcono: Colores.primario,
                      hint: 'Ej. Cálculo II',
                      controller: _nombre,
                      onChanged: (v) => vm.actualizar(nombre: v),
                    ),
                    const SizedBox(height: 16),
                    CampoTexto(
                      etiqueta: 'Horas de estudio independiente (sílabo)',
                      icono: Icons.schedule,
                      colorIcono: Colores.primario,
                      hint: 'Ej. 96',
                      teclado: TextInputType.number,
                      controller: _horas,
                      onChanged: (v) => vm.actualizar(horas: v),
                    ),
                    const SizedBox(height: 16),
                    CampoTexto(
                      etiqueta: 'Duración del semestre (semanas)',
                      icono: Icons.calendar_today_outlined,
                      colorIcono: Colores.primario,
                      hint: 'Ej. 16',
                      teclado: TextInputType.number,
                      controller: _semanas,
                      ayuda: 'Entre 1 y 24 semanas',
                      onChanged: (v) => vm.actualizar(semanas: v),
                    ),
                    const SizedBox(height: 16),
                    if (vm.valido) ...[
                      _MetaCalculada(viewModel: vm),
                      const SizedBox(height: 16),
                      const Text('¿Cuánto es al día?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _PorDia(titulo: 'Estudiando 5 días', valor: '${vm.porDia(5)} al día')),
                          const SizedBox(width: 12),
                          Expanded(child: _PorDia(titulo: 'Estudiando 7 días', valor: '${vm.porDia(7)} al día')),
                        ],
                      ),
                    ] else if (vm.mostrarError || vm.guardar.error)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCEBEB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.error_outline, size: 20, color: Color(0xFFA32D2D)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Revisa los campos: escribe el nombre, unas horas mayores a 0 y un '
                                'semestre entre 1 y 24 semanas.',
                                style: TextStyle(fontSize: 13, height: 18 / 13, color: Color(0xFFA32D2D)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: vm.valido && !vm.guardar.running ? vm.guardar.execute : null,
                      child: const Text('Registrar materia'),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(onPressed: _salir, child: const Text('Cancelar')),
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

/// "Tu meta semanal será X h por semana".
class _MetaCalculada extends StatelessWidget {
  const _MetaCalculada({required this.viewModel});

  final AgregarMateriaViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colores.indigoSuave,
        border: Border.all(color: Colores.indigoClaro),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CirculoIcono(
            size: 48,
            fondo: Colores.primario,
            child: Icon(Icons.track_changes, size: 24, color: Colores.blanco),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tu meta semanal será', style: TextStyle(fontSize: 12, color: Colores.textoSecundario)),
                Text(
                  '${vm.metaTexto} h por semana',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colores.primario),
                ),
                Text(
                  '${vm.horasTexto} h de estudio independiente ÷ ${vm.semanas} semanas del semestre',
                  style: const TextStyle(fontSize: 12, height: 16 / 12, color: Colores.textoSecundario),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PorDia extends StatelessWidget {
  const _PorDia({required this.titulo, required this.valor});

  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colores.borde),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontSize: 12, color: Colores.textoSecundario)),
          const SizedBox(height: 2),
          Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

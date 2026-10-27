import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';
import '../../core/themes/colores.dart';
import '../../core/ui/comunes.dart';
import '../../core/ui/tarjeta_materia.dart';
import '../view_models/materias_viewmodel.dart';

/// Pantalla 04 · Mis materias.
class MateriasScreen extends StatelessWidget {
  const MateriasScreen({super.key, required this.viewModel});

  final MateriasViewModel viewModel;

  Future<void> _ir(BuildContext context, String ruta) async {
    await context.push(ruta);
    viewModel.cargar.execute(); // Recarga al volver.
  }

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    return Scaffold(
      appBar: Encabezado(
        titulo: 'Mis materias',
        acciones: [
          IconButton(
            tooltip: 'Agregar materia',
            onPressed: () => _ir(context, Routes.agregarMateria),
            icon: const Icon(Icons.add, color: Colores.primario),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          children: [
            if (vm.consejoVisible) ...[
              Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                decoration: BoxDecoration(color: Colores.indigoSuave, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 20, color: Colores.primario),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Un consejo: ',
                              style: TextStyle(fontWeight: FontWeight.w700, color: Colores.primario),
                            ),
                            TextSpan(
                              text: 'ten a la mano el sílabo de cada materia. Con sus horas reales de '
                                  'estudio independiente, tu meta semanal será más precisa.',
                            ),
                          ],
                        ),
                        style: TextStyle(fontSize: 13, height: 18 / 13, color: Colores.textoSecundario),
                      ),
                    ),
                    SizedBox.square(
                      dimension: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        tooltip: 'Cerrar consejo',
                        onPressed: vm.cerrarConsejo,
                        icon: const Icon(Icons.close, size: 16, color: Colores.textoSecundario),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (vm.materias.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text('Aún no tienes materias', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    SizedBox(height: 6),
                    Text(
                      'Agrega tu primera materia con las horas del sílabo para empezar a estudiar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colores.textoSecundario),
                    ),
                  ],
                ),
              ),
            for (final r in vm.materias) ...[
              TarjetaMateria(
                nombre: r.materia.nombre,
                detalle: r.detalle,
                progreso: r.progreso,
                onTap: () => _ir(context, Routes.nuevaSesionDe(r.materia.id)),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 4),
            OutlinedButton.icon(
              onPressed: () => _ir(context, Routes.agregarMateria),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Agregar materia'),
            ),
          ],
        ),
      ),
    );
  }
}

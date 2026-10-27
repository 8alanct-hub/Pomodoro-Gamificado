import 'package:flutter/material.dart';

import '../themes/colores.dart';
import 'comunes.dart';

/// Tarjeta de materia de Inicio y Mis materias: ícono, nombre, horas de la
/// semana, porcentaje y barra.
class TarjetaMateria extends StatelessWidget {
  const TarjetaMateria({
    super.key,
    required this.nombre,
    required this.detalle,
    required this.progreso,
    this.onTap,
  });

  final String nombre;
  final String detalle;

  /// De 0 a 1.
  final double progreso;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tarjeta(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              const CirculoIcono(
                radio: 12,
                child: Icon(Icons.menu_book_outlined, size: 20, color: Colores.primario),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text(detalle, style: const TextStyle(fontSize: 12, color: Colores.textoSecundario)),
                  ],
                ),
              ),
              Text(
                '${(progreso * 100).round()}%',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colores.primario),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BarraProgreso(valor: progreso),
        ],
      ),
    );
  }
}

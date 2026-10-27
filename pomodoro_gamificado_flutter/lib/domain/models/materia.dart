import 'estado_avance.dart';

/// Materia registrada por el estudiante (RF-003).
class Materia {
  const Materia({
    required this.id,
    required this.nombre,
    required this.horasTotales,
    required this.semanasSemestre,
    this.minutosEstudiados = 0,
  });

  /// Rango válido de semanas del semestre (RF-003 CA-001).
  static const int semanasMin = 1;
  static const int semanasMax = 24;

  final String id;
  final String nombre;

  /// Horas de estudio independiente según el sílabo.
  final double horasTotales;
  final int semanasSemestre;
  final int minutosEstudiados;

  /// Meta semanal en horas: horas totales ÷ semanas del semestre (RF-012).
  double get metaSemanalHoras => horasTotales / semanasSemestre;

  /// Porcentaje de la meta total cumplido, de 0 a 1.
  double get progreso =>
      (minutosEstudiados / 60 / horasTotales).clamp(0, 1).toDouble();

  bool get metaCompletada => minutosEstudiados / 60 >= horasTotales;

  /// Compara lo estudiado con lo esperado hasta [semanaActual] (RF-012 CA-002).
  EstadoAvance estadoAvance(int semanaActual) {
    final esperadoMin = metaSemanalHoras * semanaActual * 60;
    if ((minutosEstudiados - esperadoMin).abs() < 1) return EstadoAvance.alDia;
    return minutosEstudiados > esperadoMin
        ? EstadoAvance.adelantado
        : EstadoAvance.atrasado;
  }

  Materia copyWith({int? minutosEstudiados}) => Materia(
    id: id,
    nombre: nombre,
    horasTotales: horasTotales,
    semanasSemestre: semanasSemestre,
    minutosEstudiados: minutosEstudiados ?? this.minutosEstudiados,
  );
}

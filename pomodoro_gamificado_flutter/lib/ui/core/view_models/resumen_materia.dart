import '../../../domain/models/materia.dart';
import '../../../domain/models/sesion_pomodoro.dart';
import '../../../utils/formato.dart';

/// Avance de una materia en la semana actual, para las tarjetas de Inicio,
/// Mis materias y Nueva sesión.
class ResumenMateria {
  const ResumenMateria({required this.materia, required this.minutosSemana});

  final Materia materia;
  final int minutosSemana;

  double get horasSemana => minutosSemana / 60;
  double get metaHoras => materia.metaSemanalHoras;
  double get progreso => metaHoras == 0 ? 0 : (horasSemana / metaHoras).clamp(0, 1).toDouble();
  double get horasRestantes => (metaHoras - horasSemana).clamp(0, double.infinity).toDouble();

  /// "3.5 h de 6 h esta semana".
  String get detalle => '${Formato.horas(horasSemana).replaceAll(' h', '')} h de ${Formato.horas(metaHoras)} esta semana';

  /// "2.5 h restantes esta semana".
  String get restantes => horasRestantes == 0
      ? 'Meta de la semana cumplida'
      : '${Formato.horas(horasRestantes)} restantes esta semana';

  /// Arma el resumen de cada materia con las sesiones de la semana.
  static List<ResumenMateria> deLaSemana(List<Materia> materias, List<SesionPomodoro> sesionesSemana) => [
    for (final m in materias)
      ResumenMateria(
        materia: m,
        minutosSemana: sesionesSemana
            .where((s) => s.materiaId == m.id)
            .fold(0, (t, s) => t + s.minutosEnfoque),
      ),
  ];
}

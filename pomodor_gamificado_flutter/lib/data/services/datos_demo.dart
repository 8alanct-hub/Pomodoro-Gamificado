import '../../domain/models/estudiante.dart';
import '../../domain/models/mascota.dart';
import '../../domain/models/materia.dart';
import '../../domain/models/sesion_pomodoro.dart';
import 'local_data_service.dart';

/// Cuentas de prueba, solo para `main_development.dart`. La contraseña de
/// todas es 12345678 y, cada vez que se inicia sesión, vuelven a sus datos
/// iniciales.
///
/// - prueba@utb.edu.co: todo cargado (materias, historial, racha, mascota,
///   conchas e insignias). Hoy no ha estudiado: el siguiente pomodoro de
///   25 min suma el día 6 de racha.
/// - nuevo@utb.edu.co: sin materias y con el huevo sin abrir, para probar el
///   primer pomodoro y la eclosión.
/// - racha@utb.edu.co: perdió la racha (huevo otra vez, 0 panes) y tiene
///   materias e historial.
abstract final class DatosDemo {
  static const contrasena = '12345678';

  static LocalDataService crear() {
    final datos = LocalDataService();
    void cuenta(String correo, String nombre, void Function(LocalDataService) cargar) {
      datos.cuentas[correo] = (
        contrasena: contrasena,
        estudiante: Estudiante(id: correo, nombre: nombre, correo: correo, programa: 'Ingeniería de Sistemas'),
        cargar: cargar,
      );
    }

    cuenta('prueba@utb.edu.co', 'Laura Martínez', _completa);
    cuenta('nuevo@utb.edu.co', 'Andrés Gómez', (_) {});
    cuenta('racha@utb.edu.co', 'Camila Torres', _rachaPerdida);
    return datos;
  }

  static const _materias = [
    Materia(id: 'calculo', nombre: 'Cálculo II', horasTotales: 96, semanasSemestre: 16),
    Materia(id: 'software', nombre: 'Ingeniería de Software', horasTotales: 96, semanasSemestre: 16),
    Materia(id: 'fisica', nombre: 'Física II', horasTotales: 64, semanasSemestre: 16),
    Materia(id: 'bases', nombre: 'Bases de Datos', horasTotales: 48, semanasSemestre: 16),
  ];

  static DateTime get _hoy {
    final a = DateTime.now();
    return DateTime(a.year, a.month, a.day);
  }

  /// Agrega sesiones de [dias] días atrás: [bloques] es la lista de minutos.
  static void _dia(LocalDataService d, int dias, List<int> bloques, {int horaInicio = 8}) {
    final dia = _hoy.subtract(Duration(days: dias));
    var hora = horaInicio;
    for (final minutos in bloques) {
      final materia = _materias[(d.sesiones.length + dias) % _materias.length].id;
      d.sesiones.add(SesionPomodoro(
        id: 'demo${d.sesiones.length}',
        materiaId: materia,
        inicio: DateTime(dia.year, dia.month, dia.day, hora),
        minutosEnfoque: minutos,
        completada: minutos >= 25,
      ));
      hora += 2;
    }
  }

  /// Historial de días anteriores (de [desde] a [hasta] días atrás).
  static void _historial(LocalDataService d, int desde, int hasta) {
    const patrones = [
      [50, 50, 25],
      [50, 25],
      [50, 50, 50],
      [25, 25],
      [50, 50],
    ];
    for (var i = desde; i <= hasta; i++) {
      if (i % 6 == 5) continue; // Algunos días sin estudio.
      _dia(d, i, patrones[i % patrones.length]);
    }
  }

  static void _sumarMinutos(LocalDataService d) {
    for (var i = 0; i < d.materias.length; i++) {
      final m = d.materias[i];
      final minutos = d.sesiones.where((s) => s.materiaId == m.id).fold(0, (t, s) => t + s.minutosEnfoque);
      d.materias[i] = m.copyWith(minutosEstudiados: minutos);
    }
  }

  /// Todo cargado. Racha de 5 días hasta ayer (hace 3 días se usó un pan).
  static void _completa(LocalDataService d) {
    d.materias.addAll(_materias);
    _dia(d, 1, [50, 50, 25]);
    _dia(d, 2, [50, 10], horaInicio: 7); // Una sesión saltada; empieza a las 7 a. m.
    _dia(d, 4, [50, 25]);
    _dia(d, 5, [50, 50, 50, 50, 50]); // Día largo: 10 pomodoros (Maratón).
    _historial(d, 7, 90); // Hace 6 días no estudió: ahí empezó la racha.
    _sumarMinutos(d);
    d.mascota = const Mascota(
      estado: EstadoMascota.nacida,
      rachaDias: 5,
      mejorRacha: 12,
      felicidad: 60,
      panes: 1,
      conchas: 10,
      recordPesca: 20,
      pecesTotales: 20,
      nombre: 'Pompi',
    );
    d.ultimoDiaConRacha = _hoy.subtract(const Duration(days: 1));
  }

  /// Perdió la racha hace unos días: la mascota volvió a ser huevo.
  static void _rachaPerdida(LocalDataService d) {
    d.materias.addAll(_materias.take(2));
    _historial(d, 4, 40);
    // Solo con las 2 materias que tiene.
    d.sesiones.removeWhere((s) => s.materiaId != 'calculo' && s.materiaId != 'software');
    _sumarMinutos(d);
    d.mascota = const Mascota(
      estado: EstadoMascota.huevo,
      rachaDias: 0,
      mejorRacha: 9,
      felicidad: 40,
      panes: 0,
      conchas: 3,
      recordPesca: 12,
      pecesTotales: 12,
      nombre: 'Coco', // Al renacer se sugiere el nombre anterior.
    );
  }
}

/// Textos de fechas y duraciones en español, sin paquetes extra.
abstract final class Formato {
  static const _dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
  static const _meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];
  static const _mesesCortos = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
  static const inicialesDias = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  static String diaSemana(DateTime d) => _dias[d.weekday - 1];
  static String mes(DateTime d) => _meses[d.month - 1];
  static String mesCorto(DateTime d) => _mesesCortos[d.month - 1];

  /// "Viernes, 23 de octubre".
  static String fechaLarga(DateTime d) => '${diaSemana(d)}, ${d.day} de ${mes(d)}';

  /// "9:00 a. m.".
  static String hora(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m ${d.hour < 12 ? 'a. m.' : 'p. m.'}';
  }

  /// Horas con un decimal: "9.5 h", "6 h".
  static String horas(double h) {
    final r = (h * 10).round() / 10;
    return r == r.roundToDouble() ? '${r.toInt()} h' : '$r h';
  }

  /// "2 h 05 min", "45 min", "3 h".
  static String duracion(int minutos) {
    if (minutos < 60) return '$minutos min';
    final h = minutos ~/ 60, m = minutos % 60;
    return m == 0 ? '$h h' : '$h h ${m.toString().padLeft(2, '0')} min';
  }

  /// Tiempo por día de la pantalla Agregar materia: "1 h 12 min", "51 min".
  static String duracionDia(double horasDia) {
    final total = (horasDia * 60).round();
    final h = total ~/ 60, m = total % 60;
    if (h == 0) return '$m min';
    return m == 0 ? '$h h' : '$h h $m min';
  }

  /// "1 concha", "2 conchas".
  static String plural(int n, String uno, String varios) => '$n ${n == 1 ? uno : varios}';

  /// Título y texto del aviso de fin de ciclo según cuántos pomodoros se
  /// completaron (llegaron a 00:00) de los propuestos.
  static ({String titulo, String texto}) finDeCiclo(int completados, int propuestos, [String materia = '']) {
    final de = materia.isEmpty ? '' : ' de $materia';
    if (completados >= propuestos) {
      return (
        titulo: '¡Terminaste tus pomodoros!',
        texto: 'Completaste los $propuestos pomodoros propuestos$de.',
      );
    }
    if (completados == 0) {
      return (
        titulo: 'Terminaste tu ciclo',
        texto: 'No completaste ninguno de los $propuestos pomodoros propuestos$de.',
      );
    }
    return (
      titulo: 'Terminaste tu ciclo',
      texto: 'Completaste $completados de $propuestos pomodoros propuestos$de.',
    );
  }

  /// Lunes 00:00 de la semana de [d].
  static DateTime inicioSemana(DateTime d) =>
      DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));

  static DateTime soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);
}

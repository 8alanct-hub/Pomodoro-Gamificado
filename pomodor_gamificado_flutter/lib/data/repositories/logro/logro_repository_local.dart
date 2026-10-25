import '../../../domain/models/logro.dart';
import '../../../utils/formato.dart';
import '../../../utils/result.dart';
import '../../services/local_data_service.dart';
import 'logro_repository.dart';

/// Calcula las 12 insignias del diseño a partir de las sesiones guardadas.
class LogroRepositoryLocal implements LogroRepository {
  LogroRepositoryLocal({required LocalDataService localDataService})
    : _data = localDataService;

  final LocalDataService _data;

  @override
  Future<Result<List<Logro>>> obtenerLogros() async {
    final sesiones = _data.sesiones;
    final completas = sesiones.where((s) => s.cuentaParaRacha).toList();
    final pomodoros = completas.fold<int>(0, (t, s) => t + s.conchasGanadas);
    final horasTotales = sesiones.fold<int>(0, (t, s) => t + s.minutosEnfoque) / 60;

    final inicioSemana = Formato.inicioSemana(DateTime.now());
    final deLaSemana = sesiones.where((s) => !s.inicio.isBefore(inicioSemana)).toList();
    final pomodorosSemana = deLaSemana.fold<int>(0, (t, s) => t + s.conchasGanadas);
    final totalMaterias = _data.materias.length;
    // Mayor número de materias distintas estudiadas en una misma semana.
    final porSemana = <DateTime, Set<String>>{};
    for (final s in sesiones) {
      porSemana.putIfAbsent(Formato.inicioSemana(s.inicio), () => {}).add(s.materiaId);
    }
    final materiasSemana = porSemana.values.fold<int>(0, (a, b) => b.length > a ? b.length : a);
    final horasSemana = deLaSemana.fold<int>(0, (t, s) => t + s.minutosEnfoque) / 60;
    final metaSemana = _data.materias.fold<double>(0, (t, m) => t + m.metaSemanalHoras);

    final porDia = <DateTime, int>{};
    for (final s in completas) {
      final d = Formato.soloFecha(s.inicio);
      porDia[d] = (porDia[d] ?? 0) + s.conchasGanadas;
    }
    final maxDia = porDia.values.fold<int>(0, (a, b) => a > b ? a : b);

    final m = _data.mascota;
    final mejor = m.mejorRacha > m.rachaDias ? m.mejorRacha : m.rachaDias;
    // Se desbloquea con la mejor racha; mientras tanto muestra la racha actual.
    int racha(int meta) => mejor >= meta ? mejor : m.rachaDias;
    final masTemprano = completas.isEmpty
        ? null
        : completas.map((s) => s.inicio).reduce((a, b) => _minutosDia(a) < _minutosDia(b) ? a : b);
    final madrugador = masTemprano != null && masTemprano.hour < 8;
    final finDeSemana = completas.any((s) => s.inicio.weekday >= DateTime.saturday);

    Logro l(String id, String nombre, String desc, num actual, num meta, [String unidad = '']) => Logro(
      id: id,
      nombre: nombre,
      descripcion: desc,
      valorActual: actual.floor(),
      valorMeta: meta.ceil(),
      unidad: unidad,
    );

    return Result.ok([
      l('primer_pomodoro', 'Primer pomodoro', 'Completa tu primer pomodoro', pomodoros, 1, 'pomodoro'),
      l('constante', 'Constante', 'Completa 5 pomodoros en una semana', pomodorosSemana, 5, 'pomodoros'),
      l('racha_7', 'Racha de 7 días', 'Estudia 7 días seguidos', racha(7), 7, 'días'),
      l('todas_materias', 'Todas tus materias', 'Estudia tus $totalMaterias materias en una semana',
          materiasSemana, totalMaterias == 0 ? 1 : totalMaterias, 'materias'),
      l('experto', 'Experto', 'Acumula 50 h de estudio', horasTotales, 50, 'h'),
      l('racha_14', 'Racha de 14 días', 'Estudia 14 días seguidos', racha(14), 14, 'días'),
      l('meta_cumplida', 'Meta cumplida', 'Cumple tu meta semanal al 100%',
          horasSemana, metaSemana == 0 ? 1 : metaSemana, 'h'),
      l('maraton', 'Maratón', 'Completa 10 pomodoros en un día', maxDia, 10, 'pomodoros'),
      l('maestro', 'Maestro', 'Acumula 150 h de estudio', horasTotales, 150, 'h'),
      l('pescador', 'Pescador experto', 'Atrapa 50 peces en Pesca rápida', m.pecesTotales, 50, 'peces'),
      Logro(
        id: 'madrugador',
        nombre: 'Madrugador',
        descripcion: 'Completa un pomodoro antes de las 8 a. m.',
        valorActual: madrugador ? 1 : 0,
        valorMeta: 1,
        nota: masTemprano == null ? 'Aún no lo logras' : 'Tu más temprano: ${Formato.hora(masTemprano)}',
      ),
      Logro(
        id: 'fin_de_semana',
        nombre: 'Fin de semana',
        descripcion: 'Completa un pomodoro un sábado o domingo',
        valorActual: finDeSemana ? 1 : 0,
        valorMeta: 1,
        nota: 'Aún no lo logras',
      ),
    ]);
  }

  static int _minutosDia(DateTime d) => d.hour * 60 + d.minute;
}


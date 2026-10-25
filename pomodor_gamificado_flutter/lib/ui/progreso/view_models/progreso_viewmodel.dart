import 'package:flutter/foundation.dart';

import '../../../data/repositories/materia/materia_repository.dart';
import '../../../data/repositories/sesion/sesion_repository.dart';
import '../../../domain/models/materia.dart';
import '../../../domain/models/sesion_pomodoro.dart';
import '../../../utils/command.dart';
import '../../../utils/formato.dart';
import '../../../utils/result.dart';

enum Periodo { semana, mes, semestre }

/// Una barra de la gráfica: un día, una semana o un mes.
class Barra {
  Barra({required this.etiqueta, required this.nombre, required this.desde, required this.hasta});

  final String etiqueta;
  final String nombre;
  final DateTime desde;
  final DateTime hasta;
  final List<FilaHistorial> filas = [];

  int get minutos => filas.fold(0, (t, f) => t + f.minutos);
  double get horas => minutos / 60;
}

/// Una fila del historial: materia, cuándo y cuántos minutos.
typedef FilaHistorial = ({String materia, String cuando, int minutos});

/// Pantalla 09 · Progreso e historial (RF-011).
class ProgresoViewModel extends ChangeNotifier {
  ProgresoViewModel({required SesionRepository sesionRepository, MateriaRepository? materiaRepository})
    : _repo = sesionRepository,
      _materias = materiaRepository {
    cargar = Command0(_cargar)..execute();
  }

  final SesionRepository _repo;
  final MateriaRepository? _materias;

  late final Command0<void> cargar;

  Periodo periodo = Periodo.semana;

  /// Barras del período; [seleccion] es la que se tocó (por defecto, la actual).
  List<Barra> barras = [];
  int seleccion = 0;
  int indiceActual = 0;

  /// "Ver todo": historial ampliado agrupado (RF-011 CA-004).
  bool ampliado = false;

  int pomodoros = 0;
  int _minutosPeriodo = 0;

  String get horasLabel => switch (periodo) {
    Periodo.semana => 'Horas esta semana',
    Periodo.mes => 'Horas este mes',
    Periodo.semestre => 'Horas del semestre',
  };

  String get tituloGrafica => switch (periodo) {
    Periodo.semana => 'Horas por día',
    Periodo.mes => 'Horas por semana',
    Periodo.semestre => 'Horas por mes',
  };

  String get tituloAmpliado => switch (periodo) {
    Periodo.semana => 'Historial de la semana',
    Periodo.mes => 'Historial del mes',
    Periodo.semestre => 'Historial del semestre',
  };

  String get horasTexto => Formato.horas(_minutosPeriodo / 60);

  /// Altura máxima de la escala de la gráfica, en horas.
  double get escala {
    final max = barras.fold<double>(0, (m, b) => b.horas > m ? b.horas : m);
    final base = switch (periodo) { Periodo.semana => 3.0, Periodo.mes => 15.0, Periodo.semestre => 60.0 };
    return max > base ? max : base;
  }

  Barra? get barraSeleccionada => barras.isEmpty ? null : barras[seleccion];

  /// La barra es un día que aún no llega.
  bool esFutura(int i) => periodo == Periodo.semana && i > indiceActual;

  String get vacioTitulo => esFutura(seleccion) ? 'Este día aún no llega' : 'No estudiaste este día';

  String get vacioTexto => esFutura(seleccion)
      ? 'Cuando completes pomodoros ese día, aparecerán aquí.'
      : 'Si un día no estudias, se usa un pan para proteger tu racha.';

  /// Grupos del historial ampliado, del más reciente al más antiguo.
  List<int> get gruposAmpliados => [
    for (var i = barras.length - 1; i >= 0; i--)
      if (!esFutura(i)) i,
  ];

  void cambiarPeriodo(Periodo p) {
    if (p == periodo) return;
    periodo = p;
    cargar.execute();
  }

  void seleccionar(int i) {
    seleccion = i;
    notifyListeners();
  }

  void alternarAmpliado() {
    ampliado = !ampliado;
    notifyListeners();
  }

  Future<Result<void>> _cargar() async {
    final hoy = Formato.soloFecha(DateTime.now());
    barras = _armarBarras(hoy);
    indiceActual = barras.indexWhere((b) => !hoy.isBefore(b.desde) && hoy.isBefore(b.hasta));
    if (indiceActual < 0) indiceActual = barras.length - 1;
    seleccion = indiceActual;

    final nombres = <String, String>{};
    final m = await _materias?.obtenerMaterias();
    if (m is Ok<List<Materia>>) {
      for (final x in m.value) {
        nombres[x.id] = x.nombre;
      }
    }
    final r = await _repo.sesionesEntre(barras.first.desde, barras.last.hasta);
    final sesiones = r is Ok<List<SesionPomodoro>> ? r.value : const <SesionPomodoro>[];
    // En "Mes" las semanas pueden tocar el mes anterior o el siguiente: los
    // totales solo cuentan los días del mes actual.
    final (desde, hasta) = periodo == Periodo.mes
        ? (DateTime(hoy.year, hoy.month), DateTime(hoy.year, hoy.month + 1))
        : (barras.first.desde, barras.last.hasta);
    final delPeriodo = sesiones.where((s) => !s.inicio.isBefore(desde) && s.inicio.isBefore(hasta));
    pomodoros = delPeriodo.fold(0, (t, s) => t + s.conchasGanadas);
    _minutosPeriodo = delPeriodo.fold(0, (t, s) => t + s.minutosEnfoque);

    for (final b in barras) {
      final deLaBarra = sesiones.where((s) => !s.inicio.isBefore(b.desde) && s.inicio.isBefore(b.hasta));
      if (periodo == Periodo.semana) {
        // Por día: una fila por sesión, con la hora.
        for (final s in deLaBarra) {
          final n = s.conchasGanadas;
          b.filas.add((
            materia: nombres[s.materiaId] ?? 'Materia',
            cuando: '${Formato.hora(s.inicio)} · ${n > 0 ? Formato.plural(n, 'pomodoro', 'pomodoros') : 'sesión corta'}',
            minutos: s.minutosEnfoque,
          ));
        }
      } else {
        // Por semana o mes: una fila por materia con el total.
        final porMateria = <String, (int, int)>{};
        for (final s in deLaBarra) {
          final (min, pom) = porMateria[s.materiaId] ?? (0, 0);
          porMateria[s.materiaId] = (min + s.minutosEnfoque, pom + s.conchasGanadas);
        }
        porMateria.forEach((id, v) {
          b.filas.add((
            materia: nombres[id] ?? 'Materia',
            cuando: Formato.plural(v.$2, 'pomodoro', 'pomodoros'),
            minutos: v.$1,
          ));
        });
      }
    }
    notifyListeners();
    return const Result.ok(null);
  }

  List<Barra> _armarBarras(DateTime hoy) {
    switch (periodo) {
      case Periodo.semana:
        final lunes = Formato.inicioSemana(hoy);
        return [
          for (var i = 0; i < 7; i++)
            () {
              final d = lunes.add(Duration(days: i));
              return Barra(
                etiqueta: Formato.inicialesDias[i],
                nombre: d == hoy ? 'Hoy, ${Formato.diaSemana(d).toLowerCase()} ${d.day}' : '${Formato.diaSemana(d)} ${d.day} de ${Formato.mes(d)}',
                desde: d,
                hasta: d.add(const Duration(days: 1)),
              );
            }(),
        ];
      case Periodo.mes:
        // Semanas (de lunes a domingo) que tocan el mes actual.
        final primero = DateTime(hoy.year, hoy.month);
        final siguienteMes = DateTime(hoy.year, hoy.month + 1);
        final lista = <Barra>[];
        var inicio = Formato.inicioSemana(primero);
        var n = 1;
        while (inicio.isBefore(siguienteMes)) {
          final fin = inicio.add(const Duration(days: 7));
          final ultimo = fin.subtract(const Duration(days: 1));
          lista.add(Barra(
            etiqueta: 'S$n',
            nombre: 'Semana $n · ${inicio.day} ${Formato.mesCorto(inicio).toLowerCase()} – '
                '${ultimo.day} ${Formato.mesCorto(ultimo).toLowerCase()}',
            desde: inicio,
            hasta: fin,
          ));
          inicio = fin;
          n++;
        }
        return lista;
      case Periodo.semestre:
        // Los últimos 3 meses hasta el actual.
        return [
          for (var k = 2; k >= 0; k--)
            () {
              final desde = DateTime(hoy.year, hoy.month - k);
              final hasta = DateTime(hoy.year, hoy.month - k + 1);
              final nombre = '${Formato.mes(desde)[0].toUpperCase()}${Formato.mes(desde).substring(1)}';
              return Barra(
                etiqueta: Formato.mesCorto(desde),
                nombre: k == 0 ? '$nombre (en curso)' : nombre,
                desde: desde,
                hasta: hasta,
              );
            }(),
        ];
    }
  }
}

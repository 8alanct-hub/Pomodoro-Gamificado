import 'package:flutter/foundation.dart';

import '../../../data/repositories/materia/materia_repository.dart';
import '../../../domain/models/materia.dart';
import '../../../utils/command.dart';
import '../../../utils/formato.dart';
import '../../../utils/result.dart';

/// Pantalla 05 · Agregar materia (RF-003).
class AgregarMateriaViewModel extends ChangeNotifier {
  AgregarMateriaViewModel({required MateriaRepository materiaRepository})
    : _repo = materiaRepository {
    guardar = Command0<Materia>(_guardar);
  }

  final MateriaRepository _repo;

  /// Al completar, la vista vuelve a Mis materias.
  late final Command0<Materia> guardar;

  String nombre = '';
  String horasTexto = '';
  String semanasTexto = '16';

  double get horas => double.tryParse(horasTexto.replaceAll(',', '.')) ?? 0;
  int get semanas => int.tryParse(semanasTexto) ?? 0;

  /// Mismas reglas que RF-003 CA-002.
  bool get valido =>
      nombre.trim().isNotEmpty && horas > 0 && semanas >= Materia.semanasMin && semanas <= Materia.semanasMax;

  /// Muestra el error solo cuando ya escribió algo.
  bool get mostrarError => !valido && (nombre.isNotEmpty || horasTexto.isNotEmpty);

  double get metaSemanal => valido ? horas / semanas : 0;

  /// "6 h", "6.5 h".
  String get metaTexto => Formato.horas(metaSemanal).replaceAll(' h', '');

  /// Tiempo por día estudiando 5 o 7 días a la semana.
  String porDia(int dias) => Formato.duracionDia(metaSemanal / dias);

  void actualizar({String? nombre, String? horas, String? semanas}) {
    this.nombre = nombre ?? this.nombre;
    horasTexto = horas ?? horasTexto;
    semanasTexto = semanas ?? semanasTexto;
    notifyListeners();
  }

  Future<Result<Materia>> _guardar() => _repo.agregarMateria(
    nombre: nombre,
    horasTotales: horas,
    semanasSemestre: semanas,
  );
}

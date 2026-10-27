import 'package:flutter/foundation.dart';

import '../../../data/repositories/logro/logro_repository.dart';
import '../../../domain/models/logro.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// Pantalla 10 · Logros e insignias (RF-009).
class LogrosViewModel extends ChangeNotifier {
  LogrosViewModel({required LogroRepository logroRepository})
    : _repo = logroRepository {
    cargar = Command0(_cargar)..execute();
  }

  final LogroRepository _repo;

  late final Command0<void> cargar;

  List<Logro> logros = [];

  List<Logro> get desbloqueadas => logros.where((l) => l.desbloqueado).toList();
  List<Logro> get bloqueadas => logros.where((l) => !l.desbloqueado).toList();
  double get avance => logros.isEmpty ? 0 : desbloqueadas.length / logros.length;

  /// "6 de 10 pomodoros" o la nota de la insignia.
  String progreso(Logro l) => l.nota ?? '${l.valorActual} de ${l.valorMeta} ${l.unidad}'.trim();

  Future<Result<void>> _cargar() async {
    final r = await _repo.obtenerLogros();
    if (r is Ok<List<Logro>>) logros = r.value;
    notifyListeners();
    return const Result.ok(null);
  }
}

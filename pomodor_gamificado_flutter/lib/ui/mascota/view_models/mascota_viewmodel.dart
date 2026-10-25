import 'package:flutter/foundation.dart';

import '../../../data/repositories/gamificacion/gamificacion_repository.dart';
import '../../../domain/models/mascota.dart';
import '../../../utils/command.dart';
import '../../../utils/formato.dart';
import '../../../utils/result.dart';

/// Pestaña Mascota: mascota virtual (11b) o huevo si no hay racha (13)
/// (RF-014, RF-015 y RF-017).
class MascotaViewModel extends ChangeNotifier {
  MascotaViewModel({required GamificacionRepository gamificacionRepository})
    : _repo = gamificacionRepository {
    cargar = Command0(_cargar)..execute();
    acariciar = Command0(_acariciar);
    guardarNombre = Command1<void, String>(_guardarNombre);
  }

  final GamificacionRepository _repo;

  late final Command0<void> cargar;
  late final Command0<void> acariciar;

  /// Nombre obligatorio si la mascota nació y aún no tiene uno.
  late final Command1<void, String> guardarNombre;

  bool get faltaNombre => !mascota.esHuevo && !mascota.tieneNombre;

  Mascota mascota = const Mascota();

  /// Globo de texto sobre la mascota.
  String mensaje = '¡Hola! Gracias por estudiar hoy.';

  /// Aviso de los panes (se abre al tocar el chip).
  bool panesAbierto = false;

  bool get puedeJugar => mascota.conchas > 0;

  /// La racha se perdió alguna vez (pantalla 13) o aún no nace.
  bool get rachaPerdida => mascota.esHuevo && mascota.mejorRacha > 0;

  String get textoPanes {
    final p = mascota.panes;
    if (p >= Mascota.maxPanes) return 'Si un día no estudias, se usa un pan para salvar tu racha.';
    final faltan = 7 - mascota.rachaDias % 7;
    return 'Si un día no estudias, se usa un pan para salvar tu racha. '
        'Recuperas el otro en ${Formato.plural(faltan, 'día', 'días')} de racha.';
  }

  void alternarPanes() {
    panesAbierto = !panesAbierto;
    notifyListeners();
  }

  Future<Result<void>> _cargar() => _actualizar(_repo.obtenerMascota());

  Future<Result<void>> _guardarNombre(String nombre) async {
    final r = await _repo.ponerNombre(nombre);
    if (r is Error<Mascota>) return Result.error(r.error);
    mascota = (r as Ok<Mascota>).value;
    mensaje = '¡Me encanta mi nombre!';
    notifyListeners();
    return const Result.ok(null);
  }

  Future<Result<void>> _acariciar() {
    mensaje = '¡Me encanta! Gracias por cuidarme.';
    return _actualizar(_repo.acariciar());
  }

  Future<Result<void>> _actualizar(Future<Result<Mascota>> accion) async {
    final r = await accion;
    if (r is Ok<Mascota>) mascota = r.value;
    notifyListeners();
    return const Result.ok(null);
  }
}

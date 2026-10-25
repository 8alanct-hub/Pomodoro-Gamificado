import '../../../domain/models/mascota.dart';
import '../../../utils/result.dart';

/// Racha, mascota, protectores y conchas (RF-010, RF-014 a RF-018).
abstract class GamificacionRepository {
  Future<Result<Mascota>> obtenerMascota();

  /// Aplica las recompensas de una sesión con [minutosEnfoque] cumplidos:
  /// suma conchas por bloque de 25 min y cuenta el día para la racha.
  /// Si el huevo eclosiona, la mascota devuelta queda en estado `nacida`.
  Future<Result<Mascota>> registrarEnfoque(int minutosEnfoque);

  /// Revisa los días sin estudiar al abrir la app: gasta panes o reinicia la
  /// racha y vuelve la mascota a huevo (RF-010 CA-002, RF-015 CA-001).
  Future<Result<Mascota>> revisarRachaDelDia();

  Future<Result<Mascota>> acariciar();

  /// Le pone nombre a la mascota (obligatorio al nacer): de 1 a 20 caracteres.
  Future<Result<Mascota>> ponerNombre(String nombre);

  /// Descuenta 1 concha para iniciar una partida (RF-017 CA-001).
  Future<Result<Mascota>> gastarConcha();

  /// Guarda una partida de Pesca rápida: actualiza récord, peces atrapados
  /// y felicidad (+3 y +1 por cada 4 puntos, máximo +20).
  Future<Result<Mascota>> guardarPartida({required int puntaje, required int peces});
}

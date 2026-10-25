import '../../domain/models/configuracion_pomodoro.dart';
import '../../domain/models/estudiante.dart';
import '../../domain/models/mascota.dart';
import '../../domain/models/materia.dart';
import '../../domain/models/sesion_pomodoro.dart';

/// Cuenta guardada en memoria.
typedef Cuenta = ({
  String contrasena,
  Estudiante estudiante,
  void Function(LocalDataService datos)? cargar,
});

/// Guarda los datos en memoria mientras la app está abierta.
///
/// Sirve para desarrollar y probar las pantallas sin Supabase. Cuando se
/// conecte la base de datos, se agrega un `SupabaseService` en esta carpeta y
/// los repositorios remotos lo usan en lugar de este servicio.
class LocalDataService {
  Estudiante? estudiante;
  final List<Materia> materias = [];
  final List<SesionPomodoro> sesiones = [];
  ConfiguracionPomodoro configuracion = const ConfiguracionPomodoro();
  Mascota mascota = const Mascota();

  /// Último día que contó para la racha.
  DateTime? ultimoDiaConRacha;

  /// Cuentas conocidas (correo → contraseña y datos). Las cuentas nuevas se
  /// agregan al registrarse; las de prueba vienen de `datos_demo.dart` y
  /// traen [Cuenta.cargar] para llenar sus datos al iniciar sesión.
  final Map<String, Cuenta> cuentas = {};

  /// Deja todo vacío (materias, sesiones, mascota y configuración).
  void reiniciar() {
    materias.clear();
    sesiones.clear();
    configuracion = const ConfiguracionPomodoro();
    mascota = const Mascota();
    ultimoDiaConRacha = null;
  }
}

/// Rutas de la app. Las pantallas navegan con `context.go(Routes.x)`.
abstract final class Routes {
  static const login = '/login';
  static const registro = '/registro';
  static const bienvenida = '/bienvenida';

  // Pestañas de la barra inferior.
  static const mascota = '/mascota';
  static const materias = '/materias';
  static const inicio = '/';
  static const progreso = '/progreso';
  static const logros = '/logros';

  // Pantallas completas (sin barra inferior).
  static const agregarMateria = '/agregar-materia';
  static const nuevaSesion = '/nueva-sesion';
  static const temporizador = '/temporizador';
  static const descanso = '/descanso';
  static const racha = '/racha';
  static const pescaRapida = '/pesca-rapida';
  static const perfil = '/perfil';

  /// Nueva sesión con una materia ya elegida.
  static String nuevaSesionDe(String materiaId) => '$nuevaSesion?materia=$materiaId';

  // [completados] cuenta los pomodoros del ciclo que llegaron a 00:00; se
  // pasa de pantalla en pantalla para el mensaje final del ciclo.

  static String temporizadorDe(String materiaId, {required int pomodoro, int completados = 0}) =>
      '$temporizador?materia=$materiaId&n=$pomodoro&c=$completados';

  static String descansoDe(
    String materiaId, {
    required int pomodoro,
    bool saltado = false,
    int completados = 0,
  }) => '$descanso?materia=$materiaId&n=$pomodoro&saltado=$saltado&c=$completados';

  /// [fin] indica que era el último pomodoro del ciclo: después de la
  /// mascota se vuelve al inicio en vez de ir al descanso.
  static String rachaDe(String materiaId, {required int pomodoro, bool fin = false, int completados = 0}) =>
      '$racha?materia=$materiaId&n=$pomodoro&fin=$fin&c=$completados';
}

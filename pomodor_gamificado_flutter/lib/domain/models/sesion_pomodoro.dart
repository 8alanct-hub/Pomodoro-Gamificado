/// Una sesión de enfoque registrada (RF-005).
class SesionPomodoro {
  const SesionPomodoro({
    required this.id,
    required this.materiaId,
    required this.inicio,
    required this.minutosEnfoque,
    required this.completada,
  });

  /// Minutos de un bloque que da 1 concha y cuenta para la racha (RF-016).
  static const int minutosPorBloque = 25;

  final String id;
  final String materiaId;
  final DateTime inicio;

  /// Minutos de enfoque realmente cumplidos (cuentan aunque se salte).
  final int minutosEnfoque;

  /// `true` si el contador llegó a 00:00.
  final bool completada;

  /// Conchas de esta sesión: bloques completos de 25 min (RF-016).
  int get conchasGanadas => conchasPara(minutosEnfoque);

  /// `true` si la sesión cuenta para la racha del día (RF-010).
  bool get cuentaParaRacha => minutosEnfoque >= minutosPorBloque;

  /// Conchas que dan [minutos] de enfoque: 50 → 2, 45 → 1, 20 → 0.
  static int conchasPara(int minutos) => minutos ~/ minutosPorBloque;
}

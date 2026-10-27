/// Duraciones del ciclo Pomodoro (RF-006).
class ConfiguracionPomodoro {
  const ConfiguracionPomodoro({
    this.enfoqueMin = 25,
    this.descansoCortoMin = 5,
    this.descansoLargoMin = 15,
    this.pomodorosPorCiclo = 4,
  });

  // Rangos permitidos (RF-006, SRS v1.1).
  static const int enfoqueMinimo = 5, enfoqueMaximo = 60, pasoEnfoque = 5;
  static const int cortoMinimo = 3, cortoMaximo = 15;
  static const int largoMinimo = 5, largoMaximo = 30;
  static const int cicloMinimo = 1, cicloMaximo = 8;

  final int enfoqueMin;
  final int descansoCortoMin;
  final int descansoLargoMin;
  final int pomodorosPorCiclo;

  /// `true` si todos los valores están dentro de rango (RF-006 CA-003).
  bool get esValida =>
      enfoqueMin >= enfoqueMinimo &&
      enfoqueMin <= enfoqueMaximo &&
      enfoqueMin % pasoEnfoque == 0 &&
      descansoCortoMin >= cortoMinimo &&
      descansoCortoMin <= cortoMaximo &&
      descansoLargoMin >= largoMinimo &&
      descansoLargoMin <= largoMaximo &&
      pomodorosPorCiclo >= cicloMinimo &&
      pomodorosPorCiclo <= cicloMaximo;

  ConfiguracionPomodoro copyWith({
    int? enfoqueMin,
    int? descansoCortoMin,
    int? descansoLargoMin,
    int? pomodorosPorCiclo,
  }) => ConfiguracionPomodoro(
    enfoqueMin: enfoqueMin ?? this.enfoqueMin,
    descansoCortoMin: descansoCortoMin ?? this.descansoCortoMin,
    descansoLargoMin: descansoLargoMin ?? this.descansoLargoMin,
    pomodorosPorCiclo: pomodorosPorCiclo ?? this.pomodorosPorCiclo,
  );
}

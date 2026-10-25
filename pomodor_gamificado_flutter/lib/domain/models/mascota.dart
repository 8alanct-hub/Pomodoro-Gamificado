/// Estado de la Mascota Pomodoro 1 (RF-014).
enum EstadoMascota { huevo, nacida }

/// Mascota, racha y recursos de gamificación del estudiante
/// (RF-010, RF-014, RF-015 y RF-016).
class Mascota {
  const Mascota({
    this.estado = EstadoMascota.huevo,
    this.rachaDias = 0,
    this.felicidad = 50,
    this.panes = maxPanes,
    this.conchas = 0,
    this.recordPesca = 0,
    this.mejorRacha = 0,
    this.pecesTotales = 0,
    this.nombre,
  });

  /// Largo máximo del nombre de la mascota.
  static const int maxNombre = 20;

  /// Máximo de protectores de racha (RF-015).
  static const int maxPanes = 2;

  final EstadoMascota estado;
  final int rachaDias;

  /// Nivel de felicidad, de 0 a 100.
  final int felicidad;

  /// Protectores de racha disponibles.
  final int panes;

  /// Fichas para los minijuegos; sin tope (RF-016).
  final int conchas;
  final int recordPesca;

  /// Racha más larga lograda (se muestra cuando la racha se reinicia).
  final int mejorRacha;

  /// Peces atrapados en todas las partidas (insignia "Pescador experto").
  final int pecesTotales;

  /// Nombre que el estudiante le pone al nacer (obligatorio). Se conserva si
  /// la mascota vuelve a ser huevo, para sugerirlo cuando nazca de nuevo.
  final String? nombre;

  bool get tieneNombre => nombre != null && nombre!.trim().isNotEmpty;

  /// Nombre para mostrar en los textos.
  String get nombreVisible => tieneNombre ? nombre! : 'Tu mascota';

  bool get esHuevo => estado == EstadoMascota.huevo;

  /// Texto del ánimo según la felicidad.
  String get animo => felicidad >= 90
      ? 'Radiante'
      : felicidad >= 70
      ? 'Muy feliz'
      : felicidad >= 45
      ? 'Contenta'
      : 'Aburrida';

  Mascota copyWith({
    EstadoMascota? estado,
    int? rachaDias,
    int? felicidad,
    int? panes,
    int? conchas,
    int? recordPesca,
    int? mejorRacha,
    int? pecesTotales,
    String? nombre,
  }) => Mascota(
    estado: estado ?? this.estado,
    rachaDias: rachaDias ?? this.rachaDias,
    felicidad: (felicidad ?? this.felicidad).clamp(0, 100),
    panes: (panes ?? this.panes).clamp(0, maxPanes),
    conchas: conchas ?? this.conchas,
    recordPesca: recordPesca ?? this.recordPesca,
    mejorRacha: mejorRacha ?? this.mejorRacha,
    pecesTotales: pecesTotales ?? this.pecesTotales,
    nombre: nombre ?? this.nombre,
  );
}

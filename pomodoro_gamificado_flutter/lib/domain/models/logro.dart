/// Insignia del estudiante (RF-009).
class Logro {
  const Logro({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.valorActual,
    required this.valorMeta,
    this.unidad = '',
    this.nota,
  });

  final String id;
  final String nombre;
  final String descripcion;
  final int valorActual;
  final int valorMeta;

  /// Unidad del avance: "días", "h", "pomodoros", "peces".
  final String unidad;

  /// Para insignias que no se miden con barra (por ejemplo, "Madrugador").
  final String? nota;

  bool get conBarra => !desbloqueado && nota == null;

  bool get desbloqueado => valorActual >= valorMeta;

  /// Avance de 0 a 1 para la barra de progreso (RF-009 CA-002).
  double get avance => (valorActual / valorMeta).clamp(0, 1).toDouble();
}

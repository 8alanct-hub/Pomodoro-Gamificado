/// Estudiante registrado (RF-001).
class Estudiante {
  const Estudiante({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.programa,
  });

  final String id;
  final String nombre;
  final String correo;
  final String programa;
}

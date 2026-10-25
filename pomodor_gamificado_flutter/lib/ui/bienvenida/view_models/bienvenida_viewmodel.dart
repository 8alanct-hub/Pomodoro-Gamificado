import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth/auth_repository.dart';

/// Pantalla 02b · Bienvenida y tutorial de 4 pasos (RF-019).
class BienvenidaViewModel extends ChangeNotifier {
  BienvenidaViewModel({required AuthRepository authRepository})
    : _auth = authRepository;

  final AuthRepository _auth;

  static const pasos = [
    (
      titulo: '¡Bienvenido a Pomodoro!',
      texto: 'Te ayudamos a cumplir tus horas de estudio independiente, una sesión a la vez.',
    ),
    (
      titulo: 'Agrega tus materias',
      texto: 'Con las horas del sílabo y las semanas del semestre calculamos tu meta semanal.',
    ),
    (
      titulo: 'Estudia con pomodoros',
      texto: '25 min de enfoque y 5 de descanso. Puedes pausar cuando lo necesites y '
          'tus minutos siempre suman a tu meta.',
    ),
    (
      titulo: '¿Qué hay dentro del huevo?',
      texto: 'Es una sorpresa. Completa tu primer pomodoro para empezar una racha y '
          'descubrirlo. Si un día no estudias, un pan protege tu racha, y cada 25 min '
          'completos ganas una concha.',
    ),
  ];

  int _paso = 0;
  int get paso => _paso;
  bool get esUltimo => _paso == pasos.length - 1;

  void siguiente() => irA(_paso + 1);

  /// Los puntos de abajo permiten saltar a cualquier paso.
  void irA(int paso) {
    final nuevo = paso.clamp(0, pasos.length - 1);
    if (nuevo == _paso) return;
    _paso = nuevo;
    notifyListeners();
  }

  /// "Saltar", "Ir al inicio" o "Agregar mi primera materia": no vuelve a
  /// mostrar el tutorial.
  void terminar() => _auth.marcarTutorialVisto();
}

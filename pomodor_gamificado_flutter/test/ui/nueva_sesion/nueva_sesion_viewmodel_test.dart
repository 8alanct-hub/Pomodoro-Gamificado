import 'package:flutter_test/flutter_test.dart';
import 'package:pomodor_gamificado_flutter/domain/models/configuracion_pomodoro.dart';
import 'package:pomodor_gamificado_flutter/ui/nueva_sesion/view_models/nueva_sesion_viewmodel.dart';

import '../../../testing/fakes/repositories/fake_configuracion_repository.dart';
import '../../../testing/fakes/repositories/fake_materia_repository.dart';
import '../../../testing/models/materia.dart';

void main() {
  late NuevaSesionViewModel vm;

  setUp(() async {
    vm = NuevaSesionViewModel(
      materiaRepository: FakeMateriaRepository([kMateria]),
      configuracionRepository: FakeConfiguracionRepository(),
    );
    await Future<void>.delayed(Duration.zero); // Espera la carga inicial.
  });

  test('selecciona la primera materia al cargar', () {
    expect(vm.materiaId, kMateria.id);
  });

  test('el descanso corto no baja de 3 min (RF-006)', () {
    for (var i = 0; i < 10; i++) {
      vm.cambiarDescansoCorto(-1);
    }
    expect(vm.config.descansoCortoMin, ConfiguracionPomodoro.cortoMinimo);
  });

  test('el enfoque sube de 5 en 5 hasta 60 min', () {
    for (var i = 0; i < 20; i++) {
      vm.cambiarEnfoque(1);
    }
    expect(vm.config.enfoqueMin, 60);
  });
}

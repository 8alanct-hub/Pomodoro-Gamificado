import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_gamificado_flutter/domain/models/sesion_pomodoro.dart';

void main() {
  group('Conchas por bloques de 25 min (RF-016)', () {
    test('50 min dan 2 conchas', () => expect(SesionPomodoro.conchasPara(50), 2));
    test('45 min dan 1 concha', () => expect(SesionPomodoro.conchasPara(45), 1));
    test('20 min no dan conchas', () => expect(SesionPomodoro.conchasPara(20), 0));
  });
}

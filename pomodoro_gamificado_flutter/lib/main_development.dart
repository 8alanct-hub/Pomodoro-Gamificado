import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/dependencies.dart';
import 'config/desarrollo.dart';
import 'main.dart';

/// Entrada de desarrollo: datos en memoria, sin Supabase.
///
/// - Cuentas de prueba (contraseña 12345678): prueba@utb.edu.co,
///   nuevo@utb.edu.co y racha@utb.edu.co. Ver `data/services/datos_demo.dart`.
/// - El reloj va 60 veces más rápido: un pomodoro de 25 min dura 25 s.
///
/// `flutter run --target lib/main_development.dart`
void main() {
  Desarrollo.velocidad = 60;
  runApp(MultiProvider(providers: providersDemo, child: const MainApp()));
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'config/dependencies.dart';
import 'config/desarrollo.dart';
import 'data/repositories/auth/auth_repository.dart';
import 'routing/router.dart';
import 'ui/core/themes/tema.dart';

/// Dirección de la API (`pomodoro_api`). Se cambia al correr la app:
/// `flutter run --dart-define=API_URL=http://10.0.2.2:8000` (emulador Android).
const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://127.0.0.1:8000');

/// Punto de entrada real: datos en Supabase a través de la API.
///
/// - Reloj rápido para probar: `--dart-define=VELOCIDAD=60` (la API debe
///   tener `MODO_DESARROLLO=true`).
/// - Sin servidor, con datos en memoria: `--target lib/main_development.dart`.
void main() {
  Desarrollo.velocidad = const int.fromEnvironment('VELOCIDAD', defaultValue: 1);
  runApp(MultiProvider(providers: providersRemote(apiUrl), child: const MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // El router se crea una sola vez para no perder la navegación.
  late final GoRouter _router = router(context.read<AuthRepository>());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pomodoro Gamificado',
      debugShowCheckedModeBanner: false,
      theme: Tema.claro,
      routerConfig: _router,
    );
  }
}

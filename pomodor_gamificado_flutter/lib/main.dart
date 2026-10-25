import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'config/dependencies.dart';
import 'data/repositories/auth/auth_repository.dart';
import 'routing/router.dart';
import 'ui/core/themes/tema.dart';

/// Punto de entrada de producción.
///
/// TODO: cuando se conecte Supabase, cambiar `providersLocal` por
/// `providersRemote`. Para desarrollar con datos en memoria se usa
/// `flutter run --target lib/main_development.dart`.
void main() {
  runApp(MultiProvider(providers: providersLocal, child: const MainApp()));
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

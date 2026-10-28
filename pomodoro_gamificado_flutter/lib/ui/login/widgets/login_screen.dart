import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';
import '../../core/themes/colores.dart';
import '../../core/ui/campo_texto.dart';
import '../view_models/login_viewmodel.dart';

/// Pantalla 01 · Iniciar sesión.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.viewModel});

  final LoginViewModel viewModel;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Encabezado(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Inicia sesión',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    etiqueta: 'Correo institucional',
                    icono: Icons.mail_outline,
                    hint: 'nombre@utb.edu.co',
                    teclado: TextInputType.emailAddress,
                    controller: _correo,
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    etiqueta: 'Contraseña',
                    icono: Icons.lock_outline,
                    hint: 'Tu contraseña',
                    oculto: true,
                    controller: _contrasena,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {}, // TODO: recuperar contraseña.
                      child: const Text(
                        'Olvidé mi contraseña',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  ListenableBuilder(
                    listenable: vm.login,
                    builder: (context, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (vm.login.error)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Correo o contraseña incorrectos.',
                              style: TextStyle(color: Colores.error, fontSize: 13),
                            ),
                          ),
                        FilledButton(
                          onPressed: vm.login.running
                              ? null
                              : () => vm.login.execute(
                                  (_correo.text.trim(), _contrasena.text),
                                ),
                          child: const Text('Iniciar sesión'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PieEnlace(
                    texto: '¿No tienes cuenta? ',
                    enlace: 'Regístrate',
                    onTap: () => context.go(Routes.registro),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bloque azul superior con el logo, el nombre y el lema.
class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(32, MediaQuery.paddingOf(context).top + 64, 32, 40),
      decoration: const BoxDecoration(
        color: Colores.primario,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: Colores.blanco,
            child: Icon(Icons.schedule, size: 46, color: Colores.primario),
          ),
          SizedBox(height: 16),
          Text(
            'Pomodoro Gamificado',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colores.blanco,
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: 280,
            child: Text(
              'Organiza tu estudio independiente y cumple tu meta semanal',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 22 / 15, color: Color(0xFFE8EAF7)),
            ),
          ),
        ],
      ),
    );
  }
}

/// "¿No tienes cuenta? Regístrate" centrado.
class _PieEnlace extends StatelessWidget {
  const _PieEnlace({required this.texto, required this.enlace, required this.onTap});

  final String texto;
  final String enlace;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(texto, style: const TextStyle(fontSize: 15, color: Colores.textoSecundario)),
        GestureDetector(
          onTap: onTap,
          child: Text(
            enlace,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colores.primario,
            ),
          ),
        ),
      ],
    );
  }
}

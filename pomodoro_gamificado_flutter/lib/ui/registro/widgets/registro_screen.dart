import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';
import '../../core/themes/colores.dart';
import '../../core/ui/campo_texto.dart';
import '../../core/ui/mensajes.dart';
import '../view_models/registro_viewmodel.dart';

/// Pantalla 02 · Crear cuenta.
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key, required this.viewModel});

  final RegistroViewModel viewModel;

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _programa = TextEditingController();
  final _contrasena = TextEditingController();
  final _confirmacion = TextEditingController();

  @override
  void dispose() {
    for (final c in [_nombre, _correo, _programa, _contrasena, _confirmacion]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
          onPressed: () => context.go(Routes.login),
        ),
        title: const Text(
          'Crear cuenta',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        children: [
          const Text(
            'Regístrate con tu correo institucional para guardar tu progreso.',
            style: TextStyle(fontSize: 15, height: 22 / 15, color: Colores.textoSecundario),
          ),
          const SizedBox(height: 14),
          CampoTexto(
            etiqueta: 'Nombre completo',
            icono: Icons.person_outline,
            hint: 'Tu nombre y apellido',
            controller: _nombre,
          ),
          const SizedBox(height: 14),
          CampoTexto(
            etiqueta: 'Correo institucional',
            icono: Icons.mail_outline,
            hint: 'nombre@utb.edu.co',
            teclado: TextInputType.emailAddress,
            controller: _correo,
          ),
          const SizedBox(height: 14),
          CampoTexto(
            etiqueta: 'Programa académico',
            icono: Icons.menu_book_outlined,
            hint: 'Ej. Ingeniería de Sistemas',
            controller: _programa,
          ),
          const SizedBox(height: 14),
          CampoTexto(
            etiqueta: 'Contraseña',
            icono: Icons.lock_outline,
            hint: 'Mínimo 8 caracteres',
            oculto: true,
            controller: _contrasena,
          ),
          const SizedBox(height: 14),
          CampoTexto(
            etiqueta: 'Confirmar contraseña',
            icono: Icons.lock_outline,
            hint: 'Repite tu contraseña',
            oculto: true,
            controller: _confirmacion,
          ),
          const SizedBox(height: 22),
          ListenableBuilder(
            listenable: vm.registrar,
            builder: (context, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (vm.registrar.error)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      mensajeDeError(vm.registrar.result),
                      style: const TextStyle(color: Colores.error, fontSize: 13),
                    ),
                  ),
                FilledButton(
                  onPressed: vm.registrar.running
                      ? null
                      : () => vm.registrar.execute((
                          nombre: _nombre.text.trim(),
                          correo: _correo.text.trim(),
                          programa: _programa.text.trim(),
                          contrasena: _contrasena.text,
                          confirmacion: _confirmacion.text,
                        )),
                  child: const Text('Crear cuenta'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¿Ya tienes cuenta? ',
                style: TextStyle(fontSize: 15, color: Colores.textoSecundario),
              ),
              GestureDetector(
                onTap: () => context.go(Routes.login),
                child: const Text(
                  'Inicia sesión',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colores.primario,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';
import '../../core/themes/colores.dart';
import '../../core/ui/campo_texto.dart';
import '../../core/ui/comunes.dart';
import '../view_models/perfil_viewmodel.dart';

/// Pantalla 03b · Mi perfil.
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key, required this.viewModel});

  final PerfilViewModel viewModel;

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _nombre = TextEditingController();
  final _programa = TextEditingController();

  PerfilViewModel get vm => widget.viewModel;

  @override
  void dispose() {
    _nombre.dispose();
    _programa.dispose();
    super.dispose();
  }

  void _editar() {
    _nombre.text = vm.nombre;
    _programa.text = vm.programa == 'Sin programa' ? '' : vm.programa;
    vm.editar();
  }

  void _volver() => context.canPop() ? context.pop() : context.go(Routes.inicio);

  Future<void> _confirmarSalida() async {
    final salir = await mostrarHoja<bool>(
      context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: CirculoIcono(
              size: 52,
              fondo: Color(0xFFFCEBEB),
              child: Icon(Icons.logout, size: 26, color: Colores.error),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '¿Cerrar sesión?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          const Text(
            'Tu progreso, tu racha y tu mascota quedan guardados. Puedes volver a entrar con tu correo institucional.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 22 / 15, color: Colores.textoSecundario),
          ),
          const SizedBox(height: 18),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colores.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
    // Al cerrar sesión, el router redirige solo al login.
    if (salir == true) vm.cerrarSesion.execute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Encabezado(titulo: 'Mi perfil', onVolver: _volver),
      body: ListenableBuilder(
        listenable: Listenable.merge([vm, vm.guardar]),
        builder: (context, _) => LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight - 36),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Iniciales, nombre y correo.
                    Center(
                      child: CirculoIcono(
                        size: 88,
                        child: Text(
                          vm.iniciales,
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colores.primario),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      vm.nombre,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vm.correo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colores.textoSecundario),
                    ),
                    const SizedBox(height: 18),
                    Tarjeta(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Datos de la cuenta',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (!vm.editando)
                                TextButton.icon(
                                  onPressed: _editar,
                                  icon: const Icon(Icons.edit_outlined, size: 16),
                                  label: const Text('Editar', style: TextStyle(fontSize: 13)),
                                ),
                            ],
                          ),
                          if (vm.guardado && !vm.editando) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF8F2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check, size: 18, color: Color(0xFF1E6B3E)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Datos actualizados',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E6B3E)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          if (vm.editando) _Edicion(vm: vm, nombre: _nombre, programa: _programa) else _Datos(vm: vm),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 18),
                    if (!vm.editando)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colores.error,
                          side: const BorderSide(color: Colores.error, width: 1.5),
                        ),
                        onPressed: vm.cerrarSesion.running ? null : _confirmarSalida,
                        icon: const Icon(Icons.logout, size: 20),
                        label: const Text('Cerrar sesión'),
                      ),
                    const SizedBox(height: 18),
                    const Text(
                      'Pomodoro Gamificado · versión 1.0',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF8A8FB0)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Filas de solo lectura: nombre, correo (con candado) y programa.
class _Datos extends StatelessWidget {
  const _Datos({required this.vm});

  final PerfilViewModel vm;

  Widget _fila(IconData icono, String etiqueta, String valor, {bool borde = true, bool bloqueado = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: borde ? const Border(bottom: BorderSide(color: Colores.borde)) : null,
      ),
      child: Row(
        children: [
          CirculoIcono(child: Icon(icono, size: 20, color: Colores.primario)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etiqueta, style: const TextStyle(fontSize: 12, color: Colores.textoSecundario)),
                Text(valor, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          if (bloqueado)
            const Icon(Icons.lock_outline, size: 16, color: Color(0xFF8A8FB0), semanticLabel: 'No se puede cambiar'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _fila(Icons.person_outline, 'Nombre completo', vm.nombre),
        _fila(Icons.mail_outline, 'Correo institucional', vm.correo, bloqueado: true),
        _fila(Icons.menu_book_outlined, 'Programa académico', vm.programa, borde: false),
      ],
    );
  }
}

/// Campos para editar nombre y programa; el correo queda bloqueado.
class _Edicion extends StatelessWidget {
  const _Edicion({required this.vm, required this.nombre, required this.programa});

  final PerfilViewModel vm;
  final TextEditingController nombre;
  final TextEditingController programa;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CampoTexto(
          etiqueta: 'Nombre completo',
          icono: Icons.person_outline,
          hint: 'Tu nombre y apellido',
          controller: nombre,
        ),
        const SizedBox(height: 14),
        const Text('Correo institucional', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFECEEF5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colores.borde),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, size: 20, color: Color(0xFF8A8FB0)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  vm.correo,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, color: Colores.textoSecundario),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'El correo no se puede cambiar porque es tu usuario.',
          style: TextStyle(fontSize: 12, color: Colores.textoSecundario),
        ),
        const SizedBox(height: 14),
        CampoTexto(
          etiqueta: 'Programa académico',
          icono: Icons.menu_book_outlined,
          hint: 'Ej. Ingeniería de Sistemas',
          controller: programa,
        ),
        if (vm.guardar.error) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFFCEBEB), borderRadius: BorderRadius.circular(12)),
            child: const Row(
              children: [
                Icon(Icons.error_outline, size: 18, color: Color(0xFFA32D2D)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Escribe tu nombre y tu programa académico.',
                    style: TextStyle(fontSize: 13, color: Color(0xFFA32D2D)),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        FilledButton(
          onPressed: vm.guardar.running
              ? null
              : () => vm.guardar.execute((nombre: nombre.text, programa: programa.text)),
          child: const Text('Guardar cambios'),
        ),
        const SizedBox(height: 4),
        TextButton(onPressed: vm.cancelar, child: const Text('Cancelar')),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../domain/models/mascota.dart';
import '../../../utils/command.dart';
import '../themes/colores.dart';
import 'mensajes.dart';

/// "¿Cómo se llamará tu mascota?": campo y botón para el nombre obligatorio
/// de la mascota al nacer.
class FormularioNombreMascota extends StatefulWidget {
  const FormularioNombreMascota({
    super.key,
    required this.guardar,
    this.sugerido,
    this.textoBoton = 'Ponerle este nombre',
    this.alGuardar,
  });

  /// Comando del ViewModel que guarda el nombre.
  final Command1<void, String> guardar;

  /// Nombre anterior, si la mascota ya había nacido antes.
  final String? sugerido;

  final String textoBoton;

  /// Se llama cuando el nombre se guardó bien (p. ej. para cerrar la hoja).
  final VoidCallback? alGuardar;

  @override
  State<FormularioNombreMascota> createState() => _FormularioNombreMascotaState();
}

class _FormularioNombreMascotaState extends State<FormularioNombreMascota> {
  late final _nombre = TextEditingController(text: widget.sugerido ?? '');

  @override
  void initState() {
    super.initState();
    _nombre.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_nombre.text.trim().isEmpty) return;
    await widget.guardar.execute(_nombre.text);
    if (mounted && widget.guardar.completed) widget.alGuardar?.call();
  }

  @override
  Widget build(BuildContext context) {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colores.borde),
    );
    return ListenableBuilder(
      listenable: widget.guardar,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '¿Cómo se llamará tu mascota?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _nombre,
            autofocus: true,
            maxLength: Mascota.maxNombre,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _guardar(),
            style: const TextStyle(fontSize: 15, color: Colores.texto),
            decoration: InputDecoration(
              hintText: 'Ej. Pompi',
              prefixIcon: const Icon(Icons.pets_outlined, size: 20, color: Colores.primario),
              filled: true,
              fillColor: Colores.superficie,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              border: borde,
              enabledBorder: borde,
              focusedBorder: borde.copyWith(borderSide: const BorderSide(color: Colores.primario)),
            ),
          ),
          if (widget.guardar.error)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                mensajeDeError(widget.guardar.result),
                style: const TextStyle(fontSize: 13, color: Colores.error),
              ),
            ),
          FilledButton(
            onPressed: _nombre.text.trim().isEmpty || widget.guardar.running ? null : _guardar,
            child: Text(widget.textoBoton),
          ),
        ],
      ),
    );
  }
}

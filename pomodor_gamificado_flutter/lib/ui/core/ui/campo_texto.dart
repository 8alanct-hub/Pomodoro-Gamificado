import 'package:flutter/material.dart';

import '../themes/colores.dart';

/// Campo del diseño: etiqueta arriba, ícono a la izquierda, fondo gris claro
/// y borde redondeado (pantallas de login, registro y agregar materia).
/// Si es [oculto] (contraseña), muestra un ojo para ver u ocultar el texto.
class CampoTexto extends StatefulWidget {
  const CampoTexto({
    super.key,
    required this.etiqueta,
    required this.icono,
    required this.controller,
    this.hint,
    this.oculto = false,
    this.teclado,
    this.onChanged,
    this.colorIcono = Colores.textoSecundario,
    this.ayuda,
  });

  final String etiqueta;
  final IconData icono;
  final TextEditingController controller;
  final String? hint;
  final bool oculto;
  final TextInputType? teclado;
  final ValueChanged<String>? onChanged;
  final Color colorIcono;

  /// Texto pequeño debajo del campo (por ejemplo, "Entre 1 y 24 semanas").
  final String? ayuda;

  @override
  State<CampoTexto> createState() => _CampoTextoState();
}

class _CampoTextoState extends State<CampoTexto> {
  /// La contraseña empieza oculta; el ojo la muestra u oculta.
  late bool _ocultar = widget.oculto;

  OutlineInputBorder _borde(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.etiqueta,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colores.texto,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          obscureText: _ocultar,
          keyboardType: widget.teclado,
          onChanged: widget.onChanged,
          style: const TextStyle(fontSize: 15, color: Colores.texto),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: Colores.textoSecundario),
            prefixIcon: Icon(widget.icono, size: 20, color: widget.colorIcono),
            suffixIcon: widget.oculto
                ? IconButton(
                    onPressed: () => setState(() => _ocultar = !_ocultar),
                    icon: Icon(
                      _ocultar ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                      color: Colores.textoSecundario,
                    ),
                    tooltip: _ocultar ? 'Mostrar contraseña' : 'Ocultar contraseña',
                  )
                : null,
            filled: true,
            fillColor: Colores.superficie,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            border: _borde(Colores.borde),
            enabledBorder: _borde(Colores.borde),
            focusedBorder: _borde(Colores.primario),
          ),
        ),
        if (widget.ayuda != null) ...[
          const SizedBox(height: 6),
          Text(widget.ayuda!, style: const TextStyle(fontSize: 12, color: Colores.textoSecundario)),
        ],
      ],
    );
  }
}

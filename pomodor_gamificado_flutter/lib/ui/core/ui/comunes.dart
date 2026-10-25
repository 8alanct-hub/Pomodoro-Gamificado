import 'package:flutter/material.dart';

import '../themes/colores.dart';

/// Encabezado de 56 px del diseño: flecha opcional, título y acciones.
class Encabezado extends StatelessWidget implements PreferredSizeWidget {
  const Encabezado({super.key, required this.titulo, this.onVolver, this.acciones = const [], this.icono = Icons.arrow_back, this.onTitulo});

  final String titulo;
  final VoidCallback? onVolver;
  final List<Widget> acciones;
  final IconData icono;

  /// Si se indica, el título se puede tocar (muestra un lápiz al lado).
  final VoidCallback? onTitulo;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: EdgeInsets.fromLTRB(onVolver == null ? 24 : 16, 16, 16, 0),
          child: Row(
            children: [
              if (onVolver != null) ...[
                SizedBox.square(
                  dimension: 44,
                  child: IconButton(
                    onPressed: onVolver,
                    icon: Icon(icono, color: Colores.texto),
                    tooltip: 'Volver',
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: onTitulo == null
                    ? Text(
                        titulo,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      )
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: Semantics(
                          button: true,
                          label: 'Cambiar nombre: $titulo',
                          child: InkWell(
                            onTap: onTitulo,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      titulo,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.edit_outlined, size: 18, color: Colores.primario),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
              ...acciones,
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra de progreso redondeada.
class BarraProgreso extends StatelessWidget {
  const BarraProgreso({
    super.key,
    required this.valor,
    this.alto = 8,
    this.color = Colores.primario,
    this.fondo = Colores.indigoClaro,
  });

  final double valor;
  final double alto;
  final Color color;
  final Color fondo;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: valor.clamp(0, 1).toDouble(),
        minHeight: alto,
        color: color,
        backgroundColor: fondo,
      ),
    );
  }
}

/// Círculo con un ícono centrado.
class CirculoIcono extends StatelessWidget {
  const CirculoIcono({
    super.key,
    required this.child,
    this.size = 40,
    this.fondo = Colores.indigoClaro,
    this.radio,
  });

  final Widget child;
  final double size;
  final Color fondo;

  /// Si se da, es un cuadrado redondeado en vez de un círculo.
  final double? radio;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fondo,
        shape: radio == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: radio == null ? null : BorderRadius.circular(radio!),
      ),
      child: child,
    );
  }
}

/// Tarjeta con borde del diseño (radio 20).
class Tarjeta extends StatelessWidget {
  const Tarjeta({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.fondo = Colores.blanco,
    this.borde = Colores.borde,
    this.anchoBorde = 1,
    this.radio = 20,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color fondo;
  final Color? borde;
  final double anchoBorde;
  final double radio;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radio),
      side: borde == null ? BorderSide.none : BorderSide(color: borde!, width: anchoBorde),
    );
    return Material(
      color: fondo,
      shape: forma,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Muestra una hoja inferior con el estilo del diseño (esquinas de 28).
Future<T?> mostrarHoja<T>(BuildContext context, {required WidgetBuilder builder, bool cerrable = true}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: cerrable,
    enableDrag: cerrable,
    useSafeArea: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
      child: builder(context),
    ),
  );
}

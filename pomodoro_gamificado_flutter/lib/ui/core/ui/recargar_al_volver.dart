import 'package:flutter/widgets.dart';

/// Índice de la pestaña de la barra inferior que se está viendo.
///
/// Lo actualiza `BarraNavegacion`. Las pestañas se conservan en memoria al
/// cambiar entre ellas, así que sin este aviso mostrarían datos viejos (por
/// ejemplo, el huevo aunque la mascota ya haya nacido).
final pestanaActiva = ValueNotifier<int>(-1);

/// Vuelve a crear la pantalla de la pestaña [indice] (y su ViewModel, que
/// carga los datos del servidor) cada vez que el estudiante regresa a ella.
class RecargarAlVolver extends StatefulWidget {
  const RecargarAlVolver({super.key, required this.indice, required this.pantalla});

  final int indice;
  final Widget Function(BuildContext context) pantalla;

  @override
  State<RecargarAlVolver> createState() => _RecargarAlVolverState();
}

class _RecargarAlVolverState extends State<RecargarAlVolver> {
  Key _clave = UniqueKey();

  /// Se crea porque esta pestaña se está abriendo: la primera carga ya ocurre
  /// al construir la pantalla, no hace falta otra.
  late int _anterior = widget.indice;

  @override
  void initState() {
    super.initState();
    pestanaActiva.addListener(_alCambiar);
  }

  void _alCambiar() {
    final actual = pestanaActiva.value;
    if (actual == widget.indice && _anterior != widget.indice && mounted) {
      setState(() => _clave = UniqueKey());
    }
    _anterior = actual;
  }

  @override
  void dispose() {
    pestanaActiva.removeListener(_alCambiar);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      KeyedSubtree(key: _clave, child: Builder(builder: widget.pantalla));
}

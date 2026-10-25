import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../themes/colores.dart';
import 'iconos_juego.dart';

/// Contenedor de las 5 pestañas: Mascota, Mis materias, Inicio, Progreso y
/// Logros. Cada pestaña conserva su estado al cambiar entre ellas.
class BarraNavegacion extends StatelessWidget {
  const BarraNavegacion({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final actual = navigationShell.currentIndex;
    Widget item(int i, String etiqueta, Widget Function(Color) icono) {
      final activo = i == actual;
      final color = activo ? Colores.primario : Colores.textoSecundario;
      return Expanded(
        child: Semantics(
          selected: activo,
          button: true,
          child: InkWell(
            onTap: () => navigationShell.goBranch(i, initialLocation: activo),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  height: 30,
                  decoration: BoxDecoration(
                    color: activo ? Colores.seleccion : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Center(child: icono(color)),
                ),
                const SizedBox(height: 4),
                Text(
                  etiqueta,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: activo ? FontWeight.w700 : FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colores.barraNavegacion,
          border: Border(top: BorderSide(color: Colores.borde)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 76,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  item(0, 'Mascota', (c) => IconoMascotaNav(color: c)),
                  item(1, 'Mis materias', (c) => Icon(Icons.menu_book_outlined, size: 22, color: c)),
                  item(2, 'Inicio', (c) => Icon(Icons.home_outlined, size: 22, color: c)),
                  item(3, 'Progreso', (c) => Icon(Icons.leaderboard_outlined, size: 22, color: c)),
                  item(4, 'Logros', (c) => Icon(Icons.emoji_events_outlined, size: 22, color: c)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

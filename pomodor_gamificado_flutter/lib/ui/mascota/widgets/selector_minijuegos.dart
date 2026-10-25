import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/assets.dart';
import '../../../domain/models/mascota.dart';
import '../../../routing/routes.dart';
import '../../../utils/formato.dart';
import '../../core/themes/colores.dart';
import '../../core/ui/comunes.dart';
import '../../core/ui/iconos_juego.dart';

/// Hoja "Minijuegos" al tocar "Jugar": Pesca rápida y "Próximamente" (RF-017).
Future<void> mostrarSelectorMinijuegos(BuildContext context, Mascota mascota) {
  final conchas = mascota.conchas;
  return mostrarHoja<void>(
    context,
    builder: (hoja) => SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Minijuegos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              CirculoIcono(
                fondo: Colores.superficie,
                child: IconButton(
                  tooltip: 'Cerrar',
                  onPressed: () => Navigator.pop(hoja),
                  icon: const Icon(Icons.close, size: 18, color: Colores.texto),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: Colores.conchaFondo, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const IconoConcha(size: 30, conBase: true),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tienes ${Formato.plural(conchas, 'concha', 'conchas')}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colores.conchaTexto),
                      ),
                      const Text(
                        'Ganas 1 por cada 25 min de pomodoro completados',
                        style: TextStyle(fontSize: 12, color: Colores.textoSecundario),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Tarjeta(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _MiniEscena(),
                        const SizedBox(height: 8),
                        const Text('Pesca rápida', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                        Text(
                          'Tu récord: ${Formato.plural(mascota.recordPesca, 'punto', 'puntos')}',
                          style: const TextStyle(fontSize: 12, color: Colores.textoSecundario),
                        ),
                        const Spacer(),
                        const SizedBox(height: 8),
                        if (conchas > 0)
                          FilledButton(
                            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                            onPressed: () {
                              Navigator.pop(hoja);
                              context.push(Routes.pescaRapida);
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [Text('Jugar · 1'), SizedBox(width: 6), IconoConcha(size: 18)],
                            ),
                          )
                        else
                          Container(
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F3F7),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Necesitas 1 concha',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colores.textoSecundario),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Tarjeta(
                    fondo: Colores.superficie,
                    borde: const Color(0xFFC9CDE0),
                    anchoBorde: 1.5,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 96,
                          decoration: BoxDecoration(
                            color: const Color(0xFFECEEF5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.lock_outline, size: 34, color: Color(0xFF8A8FB0)),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Próximamente',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colores.textoSecundario),
                        ),
                        const Text(
                          'Nuevos juegos muy pronto',
                          style: TextStyle(fontSize: 12, color: Colores.textoSecundario),
                        ),
                        const Spacer(),
                        const SizedBox(height: 8),
                        Container(
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colores.borde),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'En camino',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF8A8FB0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (conchas == 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colores.indigoSuave, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'No tienes conchas. Completa un pomodoro de '),
                        TextSpan(text: '25 minutos o más', style: TextStyle(fontWeight: FontWeight.w700)),
                        TextSpan(text: ' y ganarás 1 concha por cada 25 min.'),
                      ],
                    ),
                    style: TextStyle(fontSize: 13, height: 18 / 13),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                    onPressed: () {
                      Navigator.pop(hoja);
                      context.push(Routes.nuevaSesion);
                    },
                    child: const Text('Iniciar pomodoro'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

/// Miniatura del juego: cielo, arena, dos peces y la mascota.
class _MiniEscena extends StatelessWidget {
  const _MiniEscena();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 96,
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Color(0xFF5DB8EA))),
            const Positioned(left: 0, right: 0, bottom: 0, height: 26, child: ColoredBox(color: Color(0xFFF6D58E))),
            const Positioned(left: 18, top: 12, child: IconoObjeto(TipoObjeto.pez, size: 26)),
            const Positioned(right: 22, top: 30, child: IconoObjeto(TipoObjeto.dorado, size: 22)),
            Positioned(
              left: 0,
              right: 0,
              bottom: 6,
              child: Center(child: Image.asset(Assets.mascota, height: 62)),
            ),
          ],
        ),
      ),
    );
  }
}

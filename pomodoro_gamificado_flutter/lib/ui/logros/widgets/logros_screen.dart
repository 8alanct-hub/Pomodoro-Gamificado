import 'package:flutter/material.dart';

import '../../../domain/models/logro.dart';
import '../../core/themes/colores.dart';
import '../../core/ui/comunes.dart';
import '../view_models/logros_viewmodel.dart';

/// Pantalla 10 · Logros.
class LogrosScreen extends StatelessWidget {
  const LogrosScreen({super.key, required this.viewModel});

  final LogrosViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    return Scaffold(
      appBar: const Encabezado(titulo: 'Logros'),
      body: RefreshIndicator(
        onRefresh: vm.cargar.execute,
        child: ListenableBuilder(
          listenable: vm,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                decoration: BoxDecoration(color: Colores.primario, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tu colección', style: TextStyle(fontSize: 12, color: Color(0xFFE8EAF7))),
                              Text(
                                '${vm.desbloqueadas.length} de ${vm.logros.length} insignias',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colores.blanco),
                              ),
                            ],
                          ),
                        ),
                        const CirculoIcono(
                          size: 48,
                          fondo: Colores.primarioOscuro,
                          child: Icon(Icons.emoji_events_outlined, size: 24, color: Colores.blanco),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    BarraProgreso(
                      valor: vm.avance,
                      alto: 10,
                      color: const Color(0xFFF5B82E),
                      fondo: Colores.primarioOscuro,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Desbloqueadas · ${vm.desbloqueadas.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (vm.desbloqueadas.isEmpty)
                const Text(
                  'Completa tu primer pomodoro para ganar tu primera insignia.',
                  style: TextStyle(fontSize: 13, color: Colores.textoSecundario),
                ),
              _Rejilla(logros: vm.desbloqueadas, viewModel: vm),
              const SizedBox(height: 16),
              Text(
                'Por desbloquear · ${vm.bloqueadas.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _Rejilla(logros: vm.bloqueadas, viewModel: vm),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dos columnas de insignias del mismo alto por fila.
class _Rejilla extends StatelessWidget {
  const _Rejilla({required this.logros, required this.viewModel});

  final List<Logro> logros;
  final LogrosViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < logros.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _Insignia(logro: logros[i], progreso: viewModel.progreso(logros[i]))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: i + 1 < logros.length
                        ? _Insignia(logro: logros[i + 1], progreso: viewModel.progreso(logros[i + 1]))
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Insignia extends StatelessWidget {
  const _Insignia({required this.logro, required this.progreso});

  final Logro logro;
  final String progreso;

  @override
  Widget build(BuildContext context) {
    final on = logro.desbloqueado;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: on ? Colores.blanco : Colores.superficie,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colores.borde),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: on ? const Color(0xFFFDF1D2) : const Color(0xFFECEEF5),
              border: on ? Border.all(color: const Color(0xFFF5B82E), width: 2) : null,
            ),
            child: Icon(
              on ? Icons.emoji_events_outlined : Icons.lock_outline,
              size: on ? 26 : 24,
              color: on ? Colores.panTexto : Colores.textoSecundario,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            logro.nombre,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: on ? Colores.texto : Colores.textoSecundario,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            logro.descripcion,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, height: 16 / 12, color: Colores.textoSecundario),
          ),
          if (!on) ...[
            const SizedBox(height: 7),
            if (logro.conBarra)
              BarraProgreso(valor: logro.avance, alto: 6, color: const Color(0xFF8A93C9), fondo: const Color(0xFFE3E5EF)),
            if (logro.conBarra) const SizedBox(height: 4),
            Text(
              progreso,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colores.textoSecundario),
            ),
          ],
        ],
      ),
    );
  }
}

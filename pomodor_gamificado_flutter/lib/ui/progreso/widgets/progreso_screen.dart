import 'package:flutter/material.dart';

import '../../../utils/formato.dart';
import '../../core/themes/colores.dart';
import '../../core/ui/comunes.dart';
import '../view_models/progreso_viewmodel.dart';

/// Pantalla 09 · Tu progreso.
class ProgresoScreen extends StatelessWidget {
  const ProgresoScreen({super.key, required this.viewModel});

  final ProgresoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    return Scaffold(
      appBar: const Encabezado(
        titulo: 'Tu progreso',
        acciones: [
          SizedBox.square(
            dimension: 44,
            child: Icon(Icons.calendar_today_outlined, color: Colores.texto),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) => vm.barras.isEmpty
            ? const SizedBox.shrink()
            : vm.ampliado
            ? _Ampliado(viewModel: vm)
            : _Normal(viewModel: vm),
      ),
    );
  }
}

class _Normal extends StatelessWidget {
  const _Normal({required this.viewModel});

  final ProgresoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    final b = vm.barraSeleccionada!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      children: [
        _Pestanas(actual: vm.periodo, onCambiar: vm.cambiarPeriodo),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _Dato(titulo: vm.horasLabel, valor: vm.horasTexto)),
            const SizedBox(width: 12),
            Expanded(child: _Dato(titulo: 'Pomodoros', valor: '${vm.pomodoros}')),
          ],
        ),
        const SizedBox(height: 16),
        Tarjeta(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(vm.tituloGrafica, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  const Text('Toca una barra', style: TextStyle(fontSize: 12, color: Colores.textoSecundario)),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 132,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < vm.barras.length; i++)
                      _BarraGrafica(
                        barra: vm.barras[i],
                        escala: vm.escala,
                        seleccionada: i == vm.seleccion,
                        actual: i == vm.indiceActual,
                        onTap: () => vm.seleccionar(i),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(
                    b.filas.isEmpty ? 'Sin sesiones' : 'Total: ${Formato.duracion(b.minutos)}',
                    style: const TextStyle(fontSize: 12, color: Colores.textoSecundario),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: vm.alternarAmpliado, child: const Text('Ver todo', style: TextStyle(fontSize: 13))),
          ],
        ),
        if (b.filas.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(color: Colores.superficie, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Text(vm.vacioTitulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  vm.vacioTexto,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, height: 17 / 12, color: Colores.textoSecundario),
                ),
              ],
            ),
          )
        else
          for (var i = 0; i < b.filas.length; i++)
            _Fila(fila: b.filas[i], borde: i < b.filas.length - 1),
      ],
    );
  }
}

/// Vista "Ver todo": todo el período agrupado, del más reciente al más antiguo.
class _Ampliado extends StatelessWidget {
  const _Ampliado({required this.viewModel});

  final ProgresoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(vm.tituloAmpliado, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                side: const BorderSide(color: Colores.borde),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              onPressed: vm.alternarAmpliado,
              child: const Text('Ver menos'),
            ),
          ],
        ),
        for (final i in vm.gruposAmpliados) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: i == vm.seleccion ? Colores.indigoSuave : Colores.blanco,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: i == vm.seleccion ? Colores.primario : Colores.borde,
                width: i == vm.seleccion ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(vm.barras[i].nombre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                      ),
                      Text(
                        Formato.duracion(vm.barras[i].minutos),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colores.primario),
                      ),
                    ],
                  ),
                ),
                if (vm.barras[i].filas.isEmpty)
                  const Text(
                    'No estudiaste en este período.',
                    style: TextStyle(fontSize: 12, color: Colores.textoSecundario),
                  ),
                for (final f in vm.barras[i].filas)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE8EAF2)))),
                    child: Row(
                      children: [
                        const CirculoIcono(size: 28, child: Icon(Icons.check, size: 14, color: Colores.primario)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(f.materia, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              Text(f.cuando, style: const TextStyle(fontSize: 12, color: Colores.textoSecundario)),
                            ],
                          ),
                        ),
                        Text(
                          Formato.duracion(f.minutos),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colores.primario),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Selector Semana / Mes / Semestre.
class _Pestanas extends StatelessWidget {
  const _Pestanas({required this.actual, required this.onCambiar});

  final Periodo actual;
  final ValueChanged<Periodo> onCambiar;

  @override
  Widget build(BuildContext context) {
    const etiquetas = {Periodo.semana: 'Semana', Periodo.mes: 'Mes', Periodo.semestre: 'Semestre'};
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colores.superficie, borderRadius: BorderRadius.circular(999)),
      child: Row(
        children: [
          for (final e in etiquetas.entries)
            Expanded(
              child: GestureDetector(
                onTap: () => onCambiar(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: e.key == actual ? Colores.blanco : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: e.key == actual ? Colores.borde : Colors.transparent),
                  ),
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: e.key == actual ? Colores.primario : Colores.textoSecundario,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.titulo, required this.valor});

  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colores.indigoSuave, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontSize: 12, color: Colores.textoSecundario)),
          const SizedBox(height: 4),
          Text(valor, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colores.primario)),
        ],
      ),
    );
  }
}

/// Barra que se puede tocar; la seleccionada va en azul oscuro.
class _BarraGrafica extends StatelessWidget {
  const _BarraGrafica({
    required this.barra,
    required this.escala,
    required this.seleccionada,
    required this.actual,
    required this.onTap,
  });

  final Barra barra;
  final double escala;
  final bool seleccionada;
  final bool actual;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final alto = (barra.horas / escala * 104).clamp(4, 104).toDouble();
    final color = seleccionada
        ? Colores.primario
        : barra.horas > 0
        ? const Color(0xFFC9CDEC)
        : Colores.borde;
    return Semantics(
      button: true,
      selected: seleccionada,
      label: '${barra.nombre}: ${Formato.horas(barra.horas)}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26,
                height: alto,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(height: 6),
              Text(
                barra.etiqueta,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: seleccionada ? FontWeight.w800 : (actual ? FontWeight.w700 : FontWeight.w400),
                  color: seleccionada ? Colores.primario : (actual ? Colores.texto : Colores.textoSecundario),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila({required this.fila, required this.borde});

  final FilaHistorial fila;
  final bool borde;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: borde ? const Border(bottom: BorderSide(color: Colores.borde)) : null,
      ),
      child: Row(
        children: [
          const CirculoIcono(size: 36, child: Icon(Icons.check, size: 18, color: Colores.primario)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fila.materia, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                Text(fila.cuando, style: const TextStyle(fontSize: 12, color: Colores.textoSecundario)),
              ],
            ),
          ),
          Text(
            Formato.duracion(fila.minutos),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colores.primario),
          ),
        ],
      ),
    );
  }
}

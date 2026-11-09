import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../fit.dart';
import '../mannequin.dart';
import '../models.dart';
import '../state.dart';
import '../widgets.dart';

class TryOnScreen extends StatefulWidget {
  const TryOnScreen({super.key, required this.prod, required this.talla});
  final Producto prod;
  final Talla talla;

  @override
  State<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends State<TryOnScreen>
    with SingleTickerProviderStateMixin {
  late Talla _talla = widget.talla;
  late final AnimationController _anim;
  double _ang = 0, _from = 0, _to = 0;
  bool _guias = true;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450))
      ..addListener(() {
        setState(() {
          _ang = _from + (_to - _from) * Curves.easeInOut.transform(_anim.value);
        });
      });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _irA(double destino) {
    _from = _ang;
    var to = destino;
    while (to - _from > math.pi) {
      to -= 2 * math.pi;
    }
    while (_from - to > math.pi) {
      to += 2 * math.pi;
    }
    _to = to;
    _anim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final prod = widget.prod;
    final perfil = appState.perfil!;
    final r = evaluar(perfil, prod, _talla);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Probador virtual'),
        backgroundColor: kFondo,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Text(prod.marca.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11, letterSpacing: 0.8, color: Color(0xFF6B6F76))),
          Text('${prod.nombre} · talle ${_talla.nombre}',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            height: 440,
            decoration: BoxDecoration(
              color: const Color(0xFFECEDEF),
              borderRadius: BorderRadius.circular(28),
            ),
            clipBehavior: Clip.antiAlias,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (d) {
                _anim.stop();
                setState(() => _ang += d.delta.dx * 0.018);
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: MannequinPainter(
                  perfil: perfil,
                  prod: prod,
                  talla: _talla,
                  angle: _ang,
                  guias: _guias,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text('Arrastrá para girar el maniquí',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B6F76))),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(label: const Text('Frente'), onPressed: () => _irA(0)),
              ActionChip(
                  label: const Text('Lateral'),
                  onPressed: () => _irA(math.pi / 2)),
              ActionChip(
                  label: const Text('Espalda'), onPressed: () => _irA(math.pi)),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text('Mostrar mis medidas en el maniquí',
                style: TextStyle(fontSize: 13)),
            value: _guias,
            activeTrackColor: kMorado,
            onChanged: (v) => setState(() => _guias = v),
          ),
          const SizedBox(height: 4),
          const Text('Cambiá de talle',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in prod.tallas)
                GestureDetector(
                  onTap: () => setState(() => _talla = t),
                  child: Container(
                    width: 56,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: t == _talla ? kMorado : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: estiloDe(evaluar(perfil, prod, t).veredicto)
                              .borde,
                          width: t == _talla ? 1.5 : 1),
                    ),
                    child: Text(t.nombre,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: t == _talla
                                ? Colors.white
                                : estiloDe(evaluar(perfil, prod, t).veredicto)
                                    .texto)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          VeredictoCard(r),
          const SizedBox(height: 12),
          ChequeosList(r),
          const SizedBox(height: 12),
          const Text(
            'El maniquí se arma con tus medidas y la tabla del talle. Es una '
            'aproximación visual: la tela y la caída real pueden variar.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B6F76), height: 1.4),
          ),
        ],
      ),
    );
  }
}

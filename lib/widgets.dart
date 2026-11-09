import 'dart:io';

import 'package:flutter/material.dart';

import 'fit.dart';
import 'models.dart';
import 'state.dart';

const kMorado = Color(0xFF7F77DD);
const kMoradoOscuro = Color(0xFF534AB7);
const kFondo = Color(0xFFF8F7F5);

class EstiloVeredicto {
  final Color bg, borde, texto;
  final String emoji;
  const EstiloVeredicto(this.bg, this.borde, this.texto, this.emoji);
}

EstiloVeredicto estiloDe(Veredicto v) => switch (v) {
      Veredicto.apto => const EstiloVeredicto(
          Color(0xFFE1F5EE), Color(0xFF5DCAA5), Color(0xFF0F6E56), '🟢'),
      Veredicto.cuidado => const EstiloVeredicto(
          Color(0xFFFAEEDA), Color(0xFFEF9F27), Color(0xFF633806), '🟡'),
      Veredicto.noRecomendado => const EstiloVeredicto(
          Color(0xFFFCEBEB), Color(0xFFF09595), Color(0xFF791F1F), '🔴'),
    };

BoxDecoration tarjeta([Color color = Colors.white]) => BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0x1F000000), width: 0.5),
    );

class VeredictoCard extends StatelessWidget {
  const VeredictoCard(this.r, {super.key});
  final Resultado r;

  @override
  Widget build(BuildContext context) {
    final st = estiloDe(r.veredicto);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: st.bg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: st.borde, width: 1.5),
      ),
      child: Row(
        children: [
          Text(st.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.titulo,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: st.texto)),
                const SizedBox(height: 4),
                Text(r.mensaje,
                    style: TextStyle(fontSize: 13, height: 1.35, color: st.texto)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FitBadge extends StatelessWidget {
  const FitBadge(this.v, {super.key});
  final Veredicto v;

  @override
  Widget build(BuildContext context) {
    final st = estiloDe(v);
    final txt = switch (v) {
      Veredicto.apto => 'Apto',
      Veredicto.cuidado => 'Cuidado',
      Veredicto.noRecomendado => 'No entra',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: st.bg, borderRadius: BorderRadius.circular(8)),
      child: Text(txt,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: st.texto)),
    );
  }
}

class ChequeosList extends StatelessWidget {
  const ChequeosList(this.r, {super.key});
  final Resultado r;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: tarjeta(),
      child: Column(
        children: [
          for (var i = 0; i < r.chequeos.length; i++) ...[
            if (i > 0) const Divider(height: 1, thickness: 0.5),
            _fila(r.chequeos[i]),
          ],
        ],
      ),
    );
  }

  Widget _fila(Chequeo c) {
    final (bg, fg, label) = switch (c.estado) {
      Estado.ok => (const Color(0xFFE1F5EE), const Color(0xFF0F6E56), 'OK'),
      Estado.justo => (
          const Color(0xFFFAEEDA),
          const Color(0xFF633806),
          'Ojo'
        ),
      Estado.fuera => (
          const Color(0xFFFCEBEB),
          const Color(0xFF791F1F),
          'No va'
        ),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.nombre,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('Vos ${c.tuyo}  ·  Prenda ${c.prenda}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B6F76))),
                Text(c.nota,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B6F76))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(8)),
            child: Text(label,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
          ),
        ],
      ),
    );
  }
}

/// Slider táctil con botones +/- para ajustar de a 1 cm.
class MedidaSlider extends StatelessWidget {
  const MedidaSlider({
    super.key,
    required this.label,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label, unit;
  final double value, min, max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    void step(double d) => onChanged((value + d).clamp(min, max).toDouble());
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      decoration: tarjeta(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B6F76))),
          Row(
            children: [
              IconButton(
                  onPressed: () => step(-1),
                  icon: const Icon(Icons.remove_circle_outline)),
              Expanded(
                child: Center(
                  child: Text.rich(TextSpan(children: [
                    TextSpan(
                        text: '${value.round()}',
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w500)),
                    TextSpan(
                        text: '  $unit',
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF6B6F76))),
                  ])),
                ),
              ),
              IconButton(
                  onPressed: () => step(1),
                  icon: const Icon(Icons.add_circle_outline)),
            ],
          ),
          Slider(
            value: value.clamp(min, max).toDouble(),
            min: min,
            max: max,
            divisions: (max - min).round(),
            activeColor: kMorado,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// Ilustración plana de la prenda (para tarjetas y detalle).
class GarmentIcon extends CustomPainter {
  GarmentIcon(this.tipo, this.color);
  final Tipo tipo;
  final Color color;

  static const _shapes = <Tipo, List<List<double>>>{
    Tipo.remera: [
      [0.38, 0.10], [0.50, 0.16], [0.62, 0.10], [0.88, 0.22], [0.96, 0.40],
      [0.80, 0.46], [0.76, 0.38], [0.76, 0.92], [0.24, 0.92], [0.24, 0.38],
      [0.20, 0.46], [0.04, 0.40], [0.12, 0.22],
    ],
    Tipo.campera: [
      [0.36, 0.08], [0.50, 0.13], [0.64, 0.08], [0.88, 0.18], [0.98, 0.80],
      [0.84, 0.82], [0.76, 0.40], [0.76, 0.94], [0.24, 0.94], [0.24, 0.40],
      [0.16, 0.82], [0.02, 0.80], [0.12, 0.18],
    ],
    Tipo.pantalon: [
      [0.26, 0.06], [0.74, 0.06], [0.80, 0.94], [0.56, 0.94], [0.50, 0.34],
      [0.44, 0.94], [0.20, 0.94],
    ],
    Tipo.vestido: [
      [0.36, 0.04], [0.42, 0.12], [0.58, 0.12], [0.64, 0.04], [0.70, 0.20],
      [0.62, 0.40], [0.84, 0.96], [0.16, 0.96], [0.38, 0.40], [0.30, 0.20],
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final pts = _shapes[tipo]!;
    final w = size.width, h = size.height;
    final path = Path()..moveTo(pts[0][0] * w, pts[0][1] * h);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i][0] * w, pts[i][1] * h);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = Color.lerp(color, Colors.black, 0.25)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeJoin = StrokeJoin.round,
    );
    if (tipo == Tipo.campera) {
      canvas.drawLine(
          Offset(0.5 * w, 0.13 * h),
          Offset(0.5 * w, 0.94 * h),
          Paint()
            ..color = Color.lerp(color, Colors.black, 0.35)!
            ..strokeWidth = 1.4);
    }
  }

  @override
  bool shouldRepaint(covariant GarmentIcon old) =>
      old.tipo != tipo || old.color != color;
}

class ProductCard extends StatelessWidget {
  const ProductCard(this.prod, {super.key, required this.onTap});
  final Producto prod;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: appState,
        builder: (context, _) => _contenido(context),
      );

  Widget _contenido(BuildContext context) {
    final perfil = appState.perfil!;
    final talla = mejorTalla(perfil, prod);
    final r = evaluar(perfil, prod, talla);
    final fav = appState.favoritos.contains(prod.id);
    final color = Color(prod.color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: tarjeta(),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: color.withAlpha(45),
                child: Stack(
                  children: [
                    Positioned.fill(child: ProductImage(prod)),
                    Positioned(top: 8, right: 8, child: FitBadge(r.veredicto)),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => appState.toggleFav(prod.id),
                        icon: Icon(
                            fav ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: fav ? Colors.redAccent : Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(prod.marca.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 10,
                          letterSpacing: 0.6,
                          color: Color(0xFF6B6F76))),
                  const SizedBox(height: 2),
                  Text(prod.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(prod.precio,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: kMoradoOscuro)),
                      const Spacer(),
                      Text('Talle ${talla.nombre}',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF6B6F76))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductGrid extends StatelessWidget {
  const ProductGrid(this.items, {super.key, required this.onOpen});
  final List<Producto> items;
  final void Function(Producto) onOpen;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.66,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) => ProductCard(items[i], onTap: () => onOpen(items[i])),
          childCount: items.length,
        ),
      ),
    );
  }
}

class TipoChips extends StatelessWidget {
  const TipoChips({super.key, required this.value, required this.onChanged});
  final Tipo? value;
  final ValueChanged<Tipo?> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, Tipo? t) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(label),
            selected: value == t,
            showCheckmark: false,
            selectedColor: kMorado,
            labelStyle: TextStyle(
                color: value == t ? Colors.white : const Color(0xFF444444),
                fontWeight: FontWeight.w500),
            backgroundColor: Colors.white,
            onSelected: (_) => onChanged(t),
          ),
        );
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          chip('Todo', null),
          for (final t in Tipo.values) chip(t.plural, t),
        ],
      ),
    );
  }
}

/// Foto de la prenda si tiene; si no, la ilustración plana con su color.
class ProductImage extends StatelessWidget {
  const ProductImage(this.prod, {super.key, this.padding = 22});
  final Producto prod;
  final double padding;

  Widget _icono() => Center(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: AspectRatio(
            aspectRatio: 0.85,
            child: CustomPaint(
                painter: GarmentIcon(prod.tipo, Color(prod.color))),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final f = prod.foto;
    if (f == null) return _icono();
    return Image.file(
      File(f),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => _icono(),
    );
  }
}

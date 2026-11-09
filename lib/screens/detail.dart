import 'package:flutter/material.dart';

import '../fit.dart';
import '../models.dart';
import '../state.dart';
import '../widgets.dart';
import 'tryon.dart';

class DetalleScreen extends StatefulWidget {
  const DetalleScreen({super.key, required this.prod});
  final Producto prod;

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  late Talla _talla = mejorTalla(appState.perfil!, widget.prod);

  @override
  Widget build(BuildContext context) {
    final prod = widget.prod;
    final perfil = appState.perfil!;
    final r = evaluar(perfil, prod, _talla);
    final color = Color(prod.color);

    return Scaffold(
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final fav = appState.favoritos.contains(prod.id);
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 300,
                color: color.withAlpha(45),
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(36),
                          child: AspectRatio(
                            aspectRatio: 0.85,
                            child: CustomPaint(
                                painter: GarmentIcon(prod.tipo, color)),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 12,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, size: 20),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 12,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: Icon(
                                fav ? Icons.favorite : Icons.favorite_border,
                                size: 20,
                                color: fav ? Colors.redAccent : Colors.black87),
                            onPressed: () => appState.toggleFav(prod.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prod.marca.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 11,
                            letterSpacing: 0.8,
                            color: Color(0xFF6B6F76))),
                    const SizedBox(height: 4),
                    Text(prod.nombre,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(prod.precio,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: kMoradoOscuro)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: const Color(0xFFEEEDFE),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(prod.corte.label,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: kMoradoOscuro)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(prod.desc,
                        style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Color(0xFF6B6F76))),
                    const SizedBox(height: 20),
                    VeredictoCard(r),
                    const SizedBox(height: 20),
                    const Text('Talle',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final t in prod.tallas) _chipTalla(perfil, prod, t),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ChequeosList(r),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: kMorado,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.accessibility_new),
                        label: const Text('Probar en mi maniquí',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  TryOnScreen(prod: prod, talla: _talla)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chipTalla(Perfil perfil, Producto prod, Talla t) {
    final v = evaluar(perfil, prod, t).veredicto;
    final sel = t == _talla;
    final st = estiloDe(v);
    return GestureDetector(
      onTap: () => setState(() => _talla = t),
      child: Container(
        width: 56,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: sel ? kMorado : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: sel ? kMoradoOscuro : st.borde, width: sel ? 1.5 : 1),
        ),
        child: Text(t.nombre,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: sel ? Colors.white : st.texto)),
      ),
    );
  }
}

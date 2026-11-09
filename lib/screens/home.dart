import 'package:flutter/material.dart';

import '../catalog.dart';
import '../fit.dart';
import '../models.dart';
import '../state.dart';
import '../widgets.dart';
import 'detail.dart';

/// Ordena el catálogo de lo que mejor te queda a lo que peor.
List<Producto> ordenadoParaPerfil(Perfil p, [Tipo? tipo]) {
  int score(Producto x) {
    final r = evaluar(p, x, mejorTalla(p, x));
    return switch (r.veredicto) {
      Veredicto.apto => 0,
      Veredicto.cuidado => 1,
      Veredicto.noRecomendado => 2,
    };
  }

  final l = catalogo.where((x) => tipo == null || x.tipo == tipo).toList();
  l.sort((a, b) => score(a).compareTo(score(b)));
  return l;
}

void abrirDetalle(BuildContext context, Producto p) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => DetalleScreen(prod: p)));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onPerfil});
  final VoidCallback onPerfil;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Tipo? _tipo;

  @override
  Widget build(BuildContext context) {
    final p = appState.perfil!;
    final items = ordenadoParaPerfil(p, _tipo);
    final saludo = p.nombre.isEmpty ? 'Hola' : 'Hola, ${p.nombre}';

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(saludo,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        const Text('Prendas ordenadas según tu perfil',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF6B6F76))),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onPerfil,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
                      decoration: BoxDecoration(
                          color: const Color(0xFFEEEDFE),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          const CircleAvatar(
                              radius: 12,
                              backgroundColor: kMorado,
                              child: Icon(Icons.person,
                                  size: 14, color: Colors.white)),
                          const SizedBox(width: 6),
                          Text('${p.altura.round()} cm · ${p.peso.round()} kg',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: kMoradoOscuro)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TipoChips(
                  value: _tipo, onChanged: (t) => setState(() => _tipo = t)),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 10),
              child: Text('Recomendados',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
          ),
          ProductGrid(items, onOpen: (x) => abrirDetalle(context, x)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../catalog.dart';
import '../models.dart';
import '../widgets.dart';
import 'home.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _q = TextEditingController();
  Tipo? _tipo;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _q.text.trim().toLowerCase();
    final items = catalogo.where((x) {
      if (_tipo != null && x.tipo != _tipo) return false;
      if (q.isEmpty) return true;
      return x.nombre.toLowerCase().contains(q) ||
          x.marca.toLowerCase().contains(q) ||
          x.tipo.singular.toLowerCase().contains(q) ||
          x.corte.label.toLowerCase().contains(q);
    }).toList();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: TextField(
                controller: _q,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Buscar prenda, marca o corte…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: q.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(_q.clear)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: TipoChips(
                value: _tipo, onChanged: (t) => setState(() => _tipo = t)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Text(
                  items.isEmpty
                      ? 'No encontramos prendas'
                      : '${items.length} prendas · tocá una para probártela',
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF6B6F76))),
            ),
          ),
          ProductGrid(items, onOpen: (x) => abrirDetalle(context, x)),
        ],
      ),
    );
  }
}

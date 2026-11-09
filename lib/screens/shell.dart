import 'package:flutter/material.dart';

import '../state.dart';
import '../widgets.dart';
import 'home.dart';
import 'profile.dart';
import 'search.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _i = 0;

  Widget _guardados() {
    final items =
        appState.productos.where((x) => appState.favoritos.contains(x.id)).toList();
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text('Guardados',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
            ),
          ),
          if (items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                      'Todavía no guardaste nada.\nTocá el corazón en una prenda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF6B6F76), height: 1.4)),
                ),
              ),
            )
          else
            ProductGrid(items, onOpen: (x) => abrirDetalle(context, x)),
        ],
      ),
    );
  }

  Widget _item(int idx, IconData off, IconData on, String label) {
    final sel = _i == idx;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _i = idx),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(sel ? on : off,
                  size: 24, color: sel ? kMorado : const Color(0xFF9A9DA3)),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: sel ? kMorado : const Color(0xFF9A9DA3))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final pages = <Widget>[
          HomeScreen(onPerfil: () => setState(() => _i = 4)),
          _guardados(),
          SearchScreen(),
          ParaVosScreen(),
          PerfilScreen(),
        ];
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: pages[_i],
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                  top: BorderSide(color: Color(0x1F000000), width: 0.5)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _item(0, Icons.home_outlined, Icons.home, 'Inicio'),
                    _item(1, Icons.favorite_border, Icons.favorite, 'Guardados'),
                    Expanded(
                      child: Center(
                        heightFactor: 1,
                        child: GestureDetector(
                          onTap: () => setState(() => _i = 2),
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: kMorado,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: _i == 2
                                      ? kMoradoOscuro
                                      : Colors.transparent,
                                  width: 3),
                            ),
                            child: const Icon(Icons.search,
                                color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                    ),
                    _item(3, Icons.auto_awesome_outlined, Icons.auto_awesome,
                        'Para vos'),
                    _item(4, Icons.person_outline, Icons.person, 'Perfil'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

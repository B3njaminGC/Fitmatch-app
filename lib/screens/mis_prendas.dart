import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../widgets.dart';
import 'prenda_form.dart';

class MisPrendasScreen extends StatelessWidget {
  const MisPrendasScreen({super.key});

  void _abrir(BuildContext context, [Producto? p]) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => PrendaForm(editar: p)));
  }

  Future<void> _borrar(BuildContext context, Producto p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar prenda'),
        content: Text('¿Borrar "${p.nombre}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Borrar')),
        ],
      ),
    );
    if (ok == true) appState.borrarProducto(p.id);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final items = appState.propios;
        return Scaffold(
          appBar: AppBar(title: const Text('Mis prendas')),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: kMorado,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Agregar prenda'),
            onPressed: () => _abrir(context),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
            children: [
              Container(
                decoration: tarjeta(),
                child: SwitchListTile(
                  title: const Text('Mostrar prendas de ejemplo',
                      style: TextStyle(fontSize: 14)),
                  subtitle: const Text('Apagalo para ver solo las tuyas',
                      style: TextStyle(fontSize: 12)),
                  value: appState.mostrarEjemplos,
                  activeTrackColor: kMorado,
                  onChanged: appState.setEjemplos,
                ),
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Todavía no cargaste prendas.\n\n'
                    'Tocá "Agregar prenda", poné marca, modelo, precio y la '
                    'tabla de talles de la tienda. FitMatch te dice si te '
                    'queda bien y te la muestra en el maniquí.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF6B6F76), height: 1.4),
                  ),
                ),
              for (final p in items)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: tarjeta(),
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 48,
                        height: 54,
                        child: ColoredBox(
                          color: Color(p.color).withAlpha(45),
                          child: ProductImage(p, padding: 6),
                        ),
                      ),
                    ),
                    title: Text(p.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${p.marca} · ${p.precio} · ${p.corte.label} · '
                        '${p.tallas.length} talles',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _borrar(context, p),
                    ),
                    onTap: () => _abrir(context, p),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

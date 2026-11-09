import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catalog.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  Perfil? perfil;
  final Set<int> favoritos = {};
  final List<Producto> propios = [];
  bool mostrarEjemplos = true;
  SharedPreferences? _prefs;

  /// Todo lo que se muestra en la tienda: ejemplos (opcional) + prendas propias.
  List<Producto> get productos =>
      [if (mostrarEjemplos) ...catalogo, ...propios];

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString('perfil');
    if (raw != null) {
      try {
        perfil = Perfil.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        perfil = null;
      }
    }
    favoritos.addAll((_prefs!.getStringList('favs') ?? []).map(int.parse));
    mostrarEjemplos = _prefs!.getBool('ejemplos') ?? true;
    for (final r in _prefs!.getStringList('propios') ?? <String>[]) {
      try {
        propios.add(Producto.fromJson(jsonDecode(r) as Map<String, dynamic>));
      } catch (_) {}
    }
  }

  Future<void> guardarPerfil(Perfil p) async {
    perfil = p;
    notifyListeners();
    await _prefs?.setString('perfil', jsonEncode(p.toJson()));
  }

  void _guardarFavs() {
    _prefs?.setStringList('favs', favoritos.map((e) => e.toString()).toList());
  }

  void _guardarPropios() {
    _prefs?.setStringList(
        'propios', propios.map((p) => jsonEncode(p.toJson())).toList());
  }

  void toggleFav(int id) {
    if (!favoritos.remove(id)) favoritos.add(id);
    notifyListeners();
    _guardarFavs();
  }

  Future<void> _borrarArchivo(String? path) async {
    if (path == null) return;
    try {
      await File(path).delete();
    } catch (_) {}
  }

  void guardarProducto(Producto p) {
    final i = propios.indexWhere((x) => x.id == p.id);
    if (i >= 0) {
      if (propios[i].foto != p.foto) _borrarArchivo(propios[i].foto);
      propios[i] = p;
    } else {
      propios.add(p);
    }
    _guardarPropios();
    notifyListeners();
  }

  void borrarProducto(int id) {
    for (final p in propios.where((x) => x.id == id)) {
      _borrarArchivo(p.foto);
    }
    propios.removeWhere((x) => x.id == id);
    favoritos.remove(id);
    _guardarPropios();
    _guardarFavs();
    notifyListeners();
  }

  void setEjemplos(bool v) {
    mostrarEjemplos = v;
    _prefs?.setBool('ejemplos', v);
    notifyListeners();
  }
}

final appState = AppState();

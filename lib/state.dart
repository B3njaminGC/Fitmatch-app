import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class AppState extends ChangeNotifier {
  Perfil? perfil;
  final Set<int> favoritos = {};
  SharedPreferences? _prefs;

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
  }

  Future<void> guardarPerfil(Perfil p) async {
    perfil = p;
    notifyListeners();
    await _prefs?.setString('perfil', jsonEncode(p.toJson()));
  }

  void toggleFav(int id) {
    if (!favoritos.remove(id)) favoritos.add(id);
    notifyListeners();
    _prefs?.setStringList('favs', favoritos.map((e) => e.toString()).toList());
  }
}

final appState = AppState();

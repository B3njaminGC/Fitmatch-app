import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctl = PageController();
  final _nombre = TextEditingController();
  int _paso = 0;
  Perfil _p = const Perfil(nombre: '');

  @override
  void dispose() {
    _ctl.dispose();
    _nombre.dispose();
    super.dispose();
  }

  void _siguiente() {
    if (_paso < 2) {
      setState(() => _paso++);
      _ctl.animateToPage(_paso,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      appState.guardarPerfil(_p.copyWith(nombre: _nombre.text.trim()));
    }
  }

  Widget _pagina(String titulo, String sub, List<Widget> hijos) => ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          Text(titulo,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(sub,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B6F76))),
          const SizedBox(height: 20),
          ...hijos,
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                children: [
                  const Text('FitMatch',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -1)),
                  const Spacer(),
                  for (var i = 0; i < 3; i++)
                    Container(
                      width: 28,
                      height: 4,
                      margin: const EdgeInsets.only(left: 6),
                      decoration: BoxDecoration(
                        color: i <= _paso ? kMorado : const Color(0xFFD3D1C7),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _ctl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _pagina('Armemos tu perfil',
                      'Lo completás una sola vez y después lo podés editar.', [
                    TextField(
                      controller: _nombre,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Tu nombre',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),
                    MedidaSlider(
                        label: 'Altura',
                        unit: 'cm',
                        value: _p.altura,
                        min: 140,
                        max: 210,
                        onChanged: (v) =>
                            setState(() => _p = _p.copyWith(altura: v))),
                    MedidaSlider(
                        label: 'Peso',
                        unit: 'kg',
                        value: _p.peso,
                        min: 35,
                        max: 160,
                        onChanged: (v) =>
                            setState(() => _p = _p.copyWith(peso: v))),
                  ]),
                  _pagina('Medidas del torso',
                      'Con una cinta métrica, o estimalas lo mejor que puedas.', [
                    MedidaSlider(
                        label: 'Pecho / busto',
                        unit: 'cm',
                        value: _p.pecho,
                        min: 60,
                        max: 150,
                        onChanged: (v) =>
                            setState(() => _p = _p.copyWith(pecho: v))),
                    MedidaSlider(
                        label: 'Cintura',
                        unit: 'cm',
                        value: _p.cintura,
                        min: 50,
                        max: 140,
                        onChanged: (v) =>
                            setState(() => _p = _p.copyWith(cintura: v))),
                  ]),
                  _pagina('Medidas inferiores',
                      'Cadera y entrepierna (de la ingle al piso).', [
                    MedidaSlider(
                        label: 'Cadera',
                        unit: 'cm',
                        value: _p.cadera,
                        min: 70,
                        max: 150,
                        onChanged: (v) =>
                            setState(() => _p = _p.copyWith(cadera: v))),
                    MedidaSlider(
                        label: 'Entrepierna',
                        unit: 'cm',
                        value: _p.entrepierna,
                        min: 55,
                        max: 100,
                        onChanged: (v) =>
                            setState(() => _p = _p.copyWith(entrepierna: v))),
                  ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: kMorado,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _siguiente,
                  child: Text(_paso < 2 ? 'Continuar' : '¡Listo, ver prendas!',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

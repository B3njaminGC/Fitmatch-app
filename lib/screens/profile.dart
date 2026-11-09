import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../tips.dart';
import '../widgets.dart';
import 'mis_prendas.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late Perfil _p = appState.perfil!;
  late final TextEditingController _nombre =
      TextEditingController(text: _p.nombre);

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  void _guardar() {
    appState.guardarPerfil(_p.copyWith(nombre: _nombre.text.trim()));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Perfil actualizado'),
        behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    Widget s(String label, String unit, double v, double min, double max,
            Perfil Function(double) set) =>
        MedidaSlider(
            label: label,
            unit: unit,
            value: v,
            min: min,
            max: max,
            onChanged: (x) => setState(() => _p = set(x)));

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Text('Tu perfil',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          const Text('Actualizá tus medidas cuando quieras',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B6F76))),
          const SizedBox(height: 16),
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
          const SizedBox(height: 12),
          s('Altura', 'cm', _p.altura, 140, 210, (x) => _p.copyWith(altura: x)),
          s('Peso', 'kg', _p.peso, 35, 160, (x) => _p.copyWith(peso: x)),
          s('Pecho / busto', 'cm', _p.pecho, 60, 150,
              (x) => _p.copyWith(pecho: x)),
          s('Cintura', 'cm', _p.cintura, 50, 140,
              (x) => _p.copyWith(cintura: x)),
          s('Cadera', 'cm', _p.cadera, 70, 150, (x) => _p.copyWith(cadera: x)),
          s('Entrepierna', 'cm', _p.entrepierna, 55, 100,
              (x) => _p.copyWith(entrepierna: x)),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: tarjeta(),
            child: ListTile(
              leading: const Icon(Icons.checkroom, color: kMoradoOscuro),
              title: const Text('Mis prendas',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Cargá tus propias prendas y sus talles'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MisPrendasScreen())),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kMorado,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _guardar,
              child: const Text('Guardar cambios',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class ParaVosScreen extends StatelessWidget {
  const ParaVosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = appState.perfil!;
    final tips = consejos(p);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Text('Para vos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          const Text('Sugerencias según tu cuerpo',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B6F76))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: tarjeta(),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: const Color(0xFFEEEDFE),
                      borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.accessibility_new, color: kMorado),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Contextura ${p.contextura} · estatura ${p.estatura}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(
                          'IMC ${p.imc.toStringAsFixed(1)} · ${p.altura.round()} cm · ${p.peso.round()} kg',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF6B6F76))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: tarjeta(),
            child: Column(
              children: [
                for (var i = 0; i < tips.length; i++) ...[
                  if (i > 0) const Divider(height: 1, thickness: 0.5),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                              color: const Color(0xFFEEEDFE),
                              borderRadius: BorderRadius.circular(11)),
                          child: Icon(tips[i].icon,
                              size: 20, color: kMoradoOscuro),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tips[i].titulo,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(tips[i].texto,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: Color(0xFF6B6F76))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

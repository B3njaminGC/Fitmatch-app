import 'package:flutter/material.dart';

import '../catalog.dart';
import '../models.dart';
import '../state.dart';
import '../widgets.dart';

const _paleta = <int>[
  0xFF2F2F33,
  0xFFE9E9EC,
  0xFF8E9196,
  0xFF1F3B4D,
  0xFF5B7FA6,
  0xFF6B5B45,
  0xFF9C8566,
  0xFFD9D4C7,
  0xFF8C4A5A,
  0xFF4F7A5A,
  0xFFB9A3D6,
  0xFFD9822B,
];

String _f(double v) => v == v.roundToDouble() ? v.round().toString() : v.toString();

double? _num(TextEditingController c) =>
    double.tryParse(c.text.trim().replaceAll(',', '.'));

/// Una fila editable de la tabla de talles.
class _Fila {
  _Fila(Talla t)
      : nombre = TextEditingController(text: t.nombre),
        lo = TextEditingController(text: _f(t.lo)),
        hi = TextEditingController(text: _f(t.hi)),
        cinLo = TextEditingController(text: t.cinLo == null ? '' : _f(t.cinLo!)),
        cinHi = TextEditingController(text: t.cinHi == null ? '' : _f(t.cinHi!)),
        cadLo = TextEditingController(text: t.cadLo == null ? '' : _f(t.cadLo!)),
        cadHi = TextEditingController(text: t.cadHi == null ? '' : _f(t.cadHi!)),
        largo = TextEditingController(text: _f(t.largo));

  _Fila.copiaDe(_Fila o)
      : nombre = TextEditingController(),
        lo = TextEditingController(text: o.lo.text),
        hi = TextEditingController(text: o.hi.text),
        cinLo = TextEditingController(text: o.cinLo.text),
        cinHi = TextEditingController(text: o.cinHi.text),
        cadLo = TextEditingController(text: o.cadLo.text),
        cadHi = TextEditingController(text: o.cadHi.text),
        largo = TextEditingController(text: o.largo.text);

  final TextEditingController nombre, lo, hi, cinLo, cinHi, cadLo, cadHi, largo;

  List<TextEditingController> get todos =>
      [nombre, lo, hi, cinLo, cinHi, cadLo, cadHi, largo];
}

class PrendaForm extends StatefulWidget {
  const PrendaForm({super.key, this.editar});
  final Producto? editar;

  @override
  State<PrendaForm> createState() => _PrendaFormState();
}

class _PrendaFormState extends State<PrendaForm> {
  late final TextEditingController _marca, _nombre, _precio, _desc;
  late Tipo _tipo;
  late Corte _corte;
  late int _color;
  late List<_Fila> _filas;
  final List<_Fila> _viejas = [];

  @override
  void initState() {
    super.initState();
    final e = widget.editar;
    _marca = TextEditingController(text: e?.marca ?? '');
    _nombre = TextEditingController(text: e?.nombre ?? '');
    _precio = TextEditingController(text: e?.precio ?? '');
    _desc = TextEditingController(text: e?.desc ?? '');
    _tipo = e?.tipo ?? Tipo.remera;
    _corte = e?.corte ?? Corte.regular;
    _color = e?.color ?? _paleta.first;
    _filas = [for (final t in (e?.tallas ?? tallasEstandar(_tipo))) _Fila(t)];
  }

  @override
  void dispose() {
    for (final c in [_marca, _nombre, _precio, _desc]) {
      c.dispose();
    }
    for (final f in [..._filas, ..._viejas]) {
      for (final c in f.todos) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _cambiarTipo(Tipo t) {
    if (t == _tipo) return;
    setState(() {
      _viejas.addAll(_filas);
      _tipo = t;
      _filas = [for (final x in tallasEstandar(t)) _Fila(x)];
    });
  }

  void _error(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));
  }

  (double, double)? _rango(
      String talle, TextEditingController a, TextEditingController b, String medida) {
    final x = _num(a), y = _num(b);
    if (x == null || y == null || x <= 0 || y <= x) {
      _error('Talle $talle: revisá $medida (el mínimo tiene que ser menor que el máximo)');
      return null;
    }
    return (x, y);
  }

  void _guardar() {
    final marca = _marca.text.trim();
    final nombre = _nombre.text.trim();
    if (marca.isEmpty || nombre.isEmpty) {
      _error('Completá la marca y el nombre de la prenda');
      return;
    }
    if (_filas.isEmpty) {
      _error('Agregá al menos un talle');
      return;
    }

    final tallas = <Talla>[];
    for (final f in _filas) {
      final n = f.nombre.text.trim();
      if (n.isEmpty) {
        _error('Falta el nombre de un talle');
        return;
      }
      final largo = _num(f.largo);
      if (largo == null || largo <= 0) {
        _error('Talle $n: revisá el largo');
        return;
      }
      final r1 = _rango(n, f.lo, f.hi, _tipo == Tipo.pantalon ? 'la cintura' : 'el pecho');
      if (r1 == null) return;

      (double, double)? rc;
      (double, double)? rh;
      if (_tipo == Tipo.vestido) {
        rc = _rango(n, f.cinLo, f.cinHi, 'la cintura');
        if (rc == null) return;
      }
      if (_tipo == Tipo.pantalon || _tipo == Tipo.vestido) {
        rh = _rango(n, f.cadLo, f.cadHi, 'la cadera');
        if (rh == null) return;
      }
      tallas.add(Talla(n, r1.$1, r1.$2,
          cinLo: rc?.$1,
          cinHi: rc?.$2,
          cadLo: rh?.$1,
          cadHi: rh?.$2,
          largo: largo));
    }

    var precio = _precio.text.trim();
    if (precio.isEmpty) {
      precio = 'Sin precio';
    } else if (!precio.startsWith('\$')) {
      precio = '\$$precio';
    }
    final desc = _desc.text.trim();

    appState.guardarProducto(Producto(
      id: widget.editar?.id ?? DateTime.now().millisecondsSinceEpoch,
      marca: marca,
      nombre: nombre,
      precio: precio,
      desc: desc.isEmpty ? '${_tipo.singular} ${_corte.label}' : desc,
      tipo: _tipo,
      corte: _corte,
      color: _color,
      tallas: tallas,
      propio: true,
    ));
    Navigator.of(context).pop();
  }

  List<(String, TextEditingController)> _campos(_Fila f) => switch (_tipo) {
        Tipo.remera || Tipo.campera => [
            ('Pecho mín', f.lo),
            ('Pecho máx', f.hi),
            ('Largo', f.largo),
          ],
        Tipo.pantalon => [
            ('Cintura mín', f.lo),
            ('Cintura máx', f.hi),
            ('Cadera mín', f.cadLo),
            ('Cadera máx', f.cadHi),
            ('Entrepierna', f.largo),
          ],
        Tipo.vestido => [
            ('Pecho mín', f.lo),
            ('Pecho máx', f.hi),
            ('Cintura mín', f.cinLo),
            ('Cintura máx', f.cinHi),
            ('Cadera mín', f.cadLo),
            ('Cadera máx', f.cadHi),
            ('Largo', f.largo),
          ],
      };

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      );

  Widget _titulo(String t, [String? sub]) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            if (sub != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(sub,
                    style: const TextStyle(
                        fontSize: 12, height: 1.35, color: Color(0xFF6B6F76))),
              ),
          ],
        ),
      );

  Widget _chip(String label, bool sel, VoidCallback onTap) => ChoiceChip(
        label: Text(label),
        selected: sel,
        showCheckmark: false,
        selectedColor: kMorado,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
            color: sel ? Colors.white : const Color(0xFF444444),
            fontWeight: FontWeight.w500),
        onSelected: (_) => onTap(),
      );

  Widget _filaUi(int i) {
    final f = _filas[i];
    return Container(
      key: ObjectKey(f),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
      decoration: tarjeta(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 96,
                child: TextField(
                  controller: f.nombre,
                  decoration: InputDecoration(
                    labelText: 'Talle',
                    isDense: true,
                    filled: true,
                    fillColor: kFondo,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Quitar talle',
                icon: const Icon(Icons.close),
                onPressed: _filas.length > 1
                    ? () => setState(() => _viejas.add(_filas.removeAt(i)))
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (label, c) in _campos(f))
                  SizedBox(
                    width: 96,
                    child: TextField(
                      controller: c,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: label,
                        isDense: true,
                        filled: true,
                        fillColor: kFondo,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.editar == null ? 'Nueva prenda' : 'Editar prenda')),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        children: [
          _titulo('Tipo de prenda',
              'Si cambiás el tipo se reinicia la tabla de talles.'),
          Wrap(
            spacing: 8,
            children: [
              for (final t in Tipo.values)
                _chip(t.singular, _tipo == t, () => _cambiarTipo(t)),
            ],
          ),
          _titulo('Datos'),
          TextField(
              controller: _marca,
              textCapitalization: TextCapitalization.words,
              decoration: _dec('Marca (ej. Zara)')),
          const SizedBox(height: 10),
          TextField(
              controller: _nombre,
              textCapitalization: TextCapitalization.sentences,
              decoration: _dec('Nombre de la prenda')),
          const SizedBox(height: 10),
          TextField(
              controller: _precio,
              keyboardType: TextInputType.text,
              decoration: _dec('Precio (ej. 24500)')),
          const SizedBox(height: 10),
          TextField(
              controller: _desc,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: _dec('Descripción (opcional)')),
          _titulo('Corte',
              'Cómo calza según la etiqueta: Slim pegado al cuerpo, Oversize muy suelto.'),
          Wrap(
            spacing: 8,
            children: [
              for (final c in Corte.values)
                _chip(c.label, _corte == c, () => setState(() => _corte = c)),
            ],
          ),
          _titulo('Color'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final c in _paleta)
                GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: _color == c ? kMorado : const Color(0x33000000),
                          width: _color == c ? 3 : 1),
                    ),
                  ),
                ),
            ],
          ),
          _titulo('Tabla de talles',
              'Poné las medidas del CUERPO (en cm) que cubre cada talle, como figura en la tabla de la tienda. '
              'El largo es el de la prenda (en pantalones, la entrepierna).'),
          for (var i = 0; i < _filas.length; i++) _filaUi(i),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Agregar talle'),
              onPressed: () => setState(() => _filas.add(_Fila.copiaDe(_filas.last))),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 54,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kMorado,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _guardar,
              child: const Text('Guardar prenda',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

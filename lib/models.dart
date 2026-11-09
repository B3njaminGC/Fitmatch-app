import 'dart:math' as math;

enum Tipo { remera, pantalon, campera, vestido }

extension TipoX on Tipo {
  String get plural => switch (this) {
        Tipo.remera => 'Remeras',
        Tipo.pantalon => 'Pantalones',
        Tipo.campera => 'Camperas',
        Tipo.vestido => 'Vestidos',
      };

  String get singular => switch (this) {
        Tipo.remera => 'Remera',
        Tipo.pantalon => 'Pantalón',
        Tipo.campera => 'Campera',
        Tipo.vestido => 'Vestido',
      };
}

enum Corte { slim, regular, relaxed, oversize }

extension CorteX on Corte {
  String get label => switch (this) {
        Corte.slim => 'Slim fit',
        Corte.regular => 'Regular fit',
        Corte.relaxed => 'Relaxed fit',
        Corte.oversize => 'Oversize',
      };

  /// Cuántos cm de circunferencia de más tiene la prenda sobre el cuerpo.
  double get holgura => switch (this) {
        Corte.slim => 4.0,
        Corte.regular => 8.0,
        Corte.relaxed => 14.0,
        Corte.oversize => 22.0,
      };

  /// Tolerancia (cm) que se suma al rango del talle.
  double get tol => switch (this) {
        Corte.slim => -1.0,
        Corte.regular => 0.0,
        Corte.relaxed => 3.0,
        Corte.oversize => 6.0,
      };

  /// Qué tan recta/boxy cae la prenda (0 = marca la cintura, 1 = caja).
  double get boxy => switch (this) {
        Corte.slim => 0.0,
        Corte.regular => 0.3,
        Corte.relaxed => 0.6,
        Corte.oversize => 0.85,
      };
}

class Perfil {
  final String nombre;
  final double altura, peso, pecho, cintura, cadera, entrepierna;

  const Perfil({
    required this.nombre,
    this.altura = 170,
    this.peso = 70,
    this.pecho = 90,
    this.cintura = 80,
    this.cadera = 95,
    this.entrepierna = 78,
  });

  Perfil copyWith({
    String? nombre,
    double? altura,
    double? peso,
    double? pecho,
    double? cintura,
    double? cadera,
    double? entrepierna,
  }) =>
      Perfil(
        nombre: nombre ?? this.nombre,
        altura: altura ?? this.altura,
        peso: peso ?? this.peso,
        pecho: pecho ?? this.pecho,
        cintura: cintura ?? this.cintura,
        cadera: cadera ?? this.cadera,
        entrepierna: entrepierna ?? this.entrepierna,
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'altura': altura,
        'peso': peso,
        'pecho': pecho,
        'cintura': cintura,
        'cadera': cadera,
        'entrepierna': entrepierna,
      };

  factory Perfil.fromJson(Map<String, dynamic> j) => Perfil(
        nombre: (j['nombre'] ?? '') as String,
        altura: (j['altura'] as num?)?.toDouble() ?? 170,
        peso: (j['peso'] as num?)?.toDouble() ?? 70,
        pecho: (j['pecho'] as num?)?.toDouble() ?? 90,
        cintura: (j['cintura'] as num?)?.toDouble() ?? 80,
        cadera: (j['cadera'] as num?)?.toDouble() ?? 95,
        entrepierna: (j['entrepierna'] as num?)?.toDouble() ?? 78,
      );

  double get imc => peso / math.pow(altura / 100, 2);

  String get contextura {
    final atletica = (pecho - cintura) >= 8 &&
        (pecho - cadera).abs() <= 6 &&
        imc >= 20 &&
        imc < 27;
    if (atletica) return 'atlética';
    if (imc < 19) return 'delgada';
    if (imc >= 27) return 'robusta';
    return 'media';
  }

  String get estatura {
    if (altura < 163) return 'baja';
    if (altura > 182) return 'alta';
    return 'media';
  }
}

class Talla {
  final String nombre;

  /// Rango corporal principal: pecho (remera, campera, vestido) o cintura (pantalón).
  final double lo, hi;
  final double? cinLo, cinHi, cadLo, cadHi;

  /// Largo de la prenda en cm (entrepierna para pantalones).
  final double largo;

  const Talla(
    this.nombre,
    this.lo,
    this.hi, {
    this.cinLo,
    this.cinHi,
    this.cadLo,
    this.cadHi,
    required this.largo,
  });

  Map<String, dynamic> toJson() => {
        'n': nombre,
        'lo': lo,
        'hi': hi,
        'cinLo': cinLo,
        'cinHi': cinHi,
        'cadLo': cadLo,
        'cadHi': cadHi,
        'largo': largo,
      };

  factory Talla.fromJson(Map<String, dynamic> j) => Talla(
        j['n'] as String,
        (j['lo'] as num).toDouble(),
        (j['hi'] as num).toDouble(),
        cinLo: (j['cinLo'] as num?)?.toDouble(),
        cinHi: (j['cinHi'] as num?)?.toDouble(),
        cadLo: (j['cadLo'] as num?)?.toDouble(),
        cadHi: (j['cadHi'] as num?)?.toDouble(),
        largo: (j['largo'] as num).toDouble(),
      );
}

class Producto {
  final int id;
  final String marca, nombre, precio, desc;
  final Tipo tipo;
  final Corte corte;
  final int color;
  final List<Talla> tallas;

  /// true si la cargó el usuario desde la app (se puede editar y borrar).
  final bool propio;

  const Producto({
    required this.id,
    required this.marca,
    required this.nombre,
    required this.precio,
    required this.desc,
    required this.tipo,
    required this.corte,
    required this.color,
    required this.tallas,
    this.propio = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'marca': marca,
        'nombre': nombre,
        'precio': precio,
        'desc': desc,
        'tipo': tipo.name,
        'corte': corte.name,
        'color': color,
        'tallas': tallas.map((t) => t.toJson()).toList(),
      };

  factory Producto.fromJson(Map<String, dynamic> j) => Producto(
        id: (j['id'] as num).toInt(),
        marca: j['marca'] as String,
        nombre: j['nombre'] as String,
        precio: j['precio'] as String,
        desc: (j['desc'] ?? '') as String,
        tipo: Tipo.values.byName(j['tipo'] as String),
        corte: Corte.values.byName(j['corte'] as String),
        color: (j['color'] as num).toInt(),
        tallas: (j['tallas'] as List)
            .map((e) => Talla.fromJson(e as Map<String, dynamic>))
            .toList(),
        propio: true,
      );
}

import 'models.dart';

enum Veredicto { apto, cuidado, noRecomendado }

enum Estado { ok, justo, fuera }

class Chequeo {
  final String nombre, tuyo, prenda, nota;
  final Estado estado;
  const Chequeo(this.nombre, this.tuyo, this.prenda, this.estado, this.nota);
}

class Resultado {
  final Veredicto veredicto;
  final List<Chequeo> chequeos;
  const Resultado(this.veredicto, this.chequeos);

  String get titulo => switch (veredicto) {
        Veredicto.apto => 'Apto para vos',
        Veredicto.cuidado => 'Cuidado',
        Veredicto.noRecomendado => 'No recomendado',
      };

  String get mensaje {
    switch (veredicto) {
      case Veredicto.apto:
        return 'Las medidas coinciden bien con tu cuerpo.';
      case Veredicto.cuidado:
        return _notas(Estado.justo);
      case Veredicto.noRecomendado:
        return _notas(Estado.fuera);
    }
  }

  String _notas(Estado e) => chequeos
      .where((c) => c.estado == e)
      .map((c) => '${c.nombre}: ${c.nota.toLowerCase()}')
      .join(' · ');
}

double largoEsperado(Perfil p, Tipo t) => switch (t) {
      Tipo.remera => p.altura * 0.385,
      Tipo.campera => p.altura * 0.395,
      Tipo.vestido => p.altura * 0.55,
      Tipo.pantalon => p.entrepierna,
    };

double medidaRef(Perfil p, Tipo t) => t == Tipo.pantalon ? p.cintura : p.pecho;

Chequeo _ancho(String n, double v, double lo, double hi, double tol) {
  final l = lo - tol, h = hi + tol;
  final tuyo = '${v.round()} cm';
  final prenda = '${l.round()}–${h.round()} cm';
  if (v > h + 6) {
    return Chequeo(n, tuyo, prenda, Estado.fuera, 'No te entra, falta ancho');
  }
  if (v < l - 6) {
    return Chequeo(n, tuyo, prenda, Estado.fuera, 'Te queda enorme');
  }
  if (v > h) {
    return Chequeo(n, tuyo, prenda, Estado.justo, 'Va a quedar ajustada');
  }
  if (v < l) {
    return Chequeo(n, tuyo, prenda, Estado.justo, 'Va a quedar suelta');
  }
  return Chequeo(n, tuyo, prenda, Estado.ok, 'Entra bien');
}

Chequeo _largo(Perfil p, Producto prod, Talla t) {
  final esp = largoEsperado(p, prod.tipo);
  final d = t.largo - esp;
  final lim = prod.tipo == Tipo.pantalon ? 3.0 : 5.0;
  final tuyo = '${esp.round()} cm';
  final prenda = '${t.largo.round()} cm';
  if (d.abs() <= lim) {
    return Chequeo('Largo', tuyo, prenda, Estado.ok, 'Largo ideal');
  }
  final muy = d.abs() > lim * 2 ? 'muy ' : '';
  final nota = d > 0 ? 'Te va a quedar ${muy}largo' : 'Te va a quedar ${muy}corto';
  return Chequeo('Largo', tuyo, prenda, Estado.justo, nota);
}

Resultado evaluar(Perfil p, Producto prod, Talla t) {
  final c = <Chequeo>[];
  switch (prod.tipo) {
    case Tipo.remera:
    case Tipo.campera:
      c.add(_ancho('Pecho', p.pecho, t.lo, t.hi, prod.corte.tol));
    case Tipo.pantalon:
      c.add(_ancho('Cintura', p.cintura, t.lo, t.hi, prod.corte.tol));
      c.add(_ancho('Cadera', p.cadera, t.cadLo!, t.cadHi!, prod.corte.tol));
    case Tipo.vestido:
      c.add(_ancho('Pecho', p.pecho, t.lo, t.hi, prod.corte.tol));
      c.add(_ancho('Cintura', p.cintura, t.cinLo!, t.cinHi!, prod.corte.tol));
      c.add(_ancho('Cadera', p.cadera, t.cadLo!, t.cadHi!, prod.corte.tol));
  }
  c.add(_largo(p, prod, t));

  Veredicto v = Veredicto.apto;
  if (c.any((x) => x.estado == Estado.fuera)) {
    v = Veredicto.noRecomendado;
  } else if (c.any((x) => x.estado == Estado.justo)) {
    v = Veredicto.cuidado;
  }
  return Resultado(v, c);
}

double _penal(Perfil p, Producto prod, Talla t) {
  var s = 0.0;
  for (final c in evaluar(p, prod, t).chequeos) {
    s += switch (c.estado) {
      Estado.ok => 0.0,
      Estado.justo => 1.0,
      Estado.fuera => 3.0,
    };
  }
  s += (medidaRef(p, prod.tipo) - (t.lo + t.hi) / 2).abs() / 100;
  return s;
}

Talla mejorTalla(Perfil p, Producto prod) {
  Talla best = prod.tallas.first;
  var bestScore = double.infinity;
  for (final t in prod.tallas) {
    final s = _penal(p, prod, t);
    if (s < bestScore) {
      bestScore = s;
      best = t;
    }
  }
  return best;
}

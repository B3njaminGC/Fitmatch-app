import 'models.dart';

const _n = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
const _pe = [
  [78.0, 84.0],
  [84.0, 92.0],
  [92.0, 100.0],
  [100.0, 108.0],
  [108.0, 116.0],
  [116.0, 126.0],
];
const _ci = [
  [62.0, 68.0],
  [68.0, 76.0],
  [76.0, 84.0],
  [84.0, 92.0],
  [92.0, 100.0],
  [100.0, 110.0],
];
const _ca = [
  [86.0, 92.0],
  [92.0, 98.0],
  [98.0, 104.0],
  [104.0, 112.0],
  [112.0, 120.0],
  [120.0, 130.0],
];

List<Talla> tallasEstandar(Tipo t) => List.generate(6, (i) {
      switch (t) {
        case Tipo.remera:
          return Talla(_n[i], _pe[i][0], _pe[i][1], largo: 62.0 + i * 3);
        case Tipo.campera:
          return Talla(_n[i], _pe[i][0], _pe[i][1], largo: 64.0 + i * 3);
        case Tipo.pantalon:
          return Talla(_n[i], _ci[i][0], _ci[i][1],
              cadLo: _ca[i][0], cadHi: _ca[i][1], largo: 76.0 + i * 1.5);
        case Tipo.vestido:
          return Talla(_n[i], _pe[i][0], _pe[i][1],
              cinLo: _ci[i][0],
              cinHi: _ci[i][1],
              cadLo: _ca[i][0],
              cadHi: _ca[i][1],
              largo: 90.0 + i * 2);
      }
    });

Producto _p(int id, String marca, String nombre, Tipo tipo, Corte corte,
        int color, String precio, String desc) =>
    Producto(
      id: id,
      marca: marca,
      nombre: nombre,
      precio: precio,
      desc: desc,
      tipo: tipo,
      corte: corte,
      color: color,
      tallas: tallasEstandar(tipo),
    );

// Datos de demostración: marcas, modelos y precios son ilustrativos.
final List<Producto> catalogo = [
  _p(1, 'Zara', 'Remera lino relaxed', Tipo.remera, Corte.relaxed, 0xFFD9D4C7,
      '\$18.990', 'Lino lavado, cuello redondo y caída suelta. Ideal para verano.'),
  _p(2, 'H&M', 'Pantalón chino slim', Tipo.pantalon, Corte.slim, 0xFF9C8566,
      '\$24.500', 'Algodón elastizado, tiro medio y pierna estrecha.'),
  _p(3, 'Mango', 'Campera denim', Tipo.campera, Corte.regular, 0xFF5B7FA6,
      '\$42.000', 'Denim con lavado vintage, cierre frontal y bolsillos.'),
  _p(4, 'Pull&Bear', 'Remera oversize', Tipo.remera, Corte.oversize, 0xFF2F2F33,
      '\$12.990', 'Algodón 100% con hombros caídos y largo extendido.'),
  _p(5, 'Zara', 'Pantalón wide leg', Tipo.pantalon, Corte.relaxed, 0xFFE8E0D0,
      '\$31.000', 'Tiro alto y pierna ancha de caída fluida.'),
  _p(6, 'Massimo Dutti', 'Campera de lana', Tipo.campera, Corte.regular,
      0xFF6B5B45, '\$68.000', 'Lana merino con botones y corte recto.'),
  _p(7, 'Bershka', 'Remera boxy tie-dye', Tipo.remera, Corte.relaxed, 0xFFB9A3D6,
      '\$9.500', 'Estampado tie-dye y corte boxy para usar en capas.'),
  _p(8, 'H&M', 'Jogger de algodón', Tipo.pantalon, Corte.regular, 0xFF8E9196,
      '\$19.900', 'Cintura elástica, puño en el tobillo y bolsillos laterales.'),
  _p(9, 'Mango', 'Vestido midi', Tipo.vestido, Corte.regular, 0xFF8C4A5A,
      '\$36.900', 'Vestido midi con cintura marcada y falda con vuelo.'),
  _p(10, 'Zara', 'Campera puffer', Tipo.campera, Corte.oversize, 0xFF1F3B4D,
      '\$55.000', 'Relleno liviano, cuello alto y volumen oversize.'),
  _p(11, "Levi's", 'Remera slim básica', Tipo.remera, Corte.slim, 0xFFE9E9EC,
      '\$14.900', 'Algodón peinado, corte pegado al cuerpo.'),
];

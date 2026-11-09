import 'package:flutter/material.dart';

import 'models.dart';

class Tip {
  final IconData icon;
  final String titulo, texto;
  const Tip(this.icon, this.titulo, this.texto);
}

List<Tip> consejos(Perfil p) {
  final t = <Tip>[];

  switch (p.contextura) {
    case 'atlética':
      t.add(const Tip(Icons.fitness_center, 'Te sugerimos cortes Slim Fit',
          'Tu contextura atlética luce mejor con prendas que acompañan el torso sin apretar.'));
      t.add(const Tip(Icons.straighten, 'Cuidá pecho y hombros',
          'Si una remera te queda justa en el pecho, subí un talle y fijate que el largo no se pase.'));
    case 'delgada':
      t.add(const Tip(Icons.layers_outlined, 'Probá capas y texturas',
          'Camperas con volumen, lino y tejidos gruesos suman presencia a tu silueta.'));
      t.add(const Tip(Icons.checkroom, 'Cortes Regular o Relaxed',
          'Evitá los talles que te queden sueltos de más: el exceso de tela te achica.'));
    case 'robusta':
      t.add(const Tip(Icons.crop_portrait, 'Cortes rectos y Regular Fit',
          'Dan comodidad y una caída limpia sin marcar de más.'));
      t.add(const Tip(Icons.palette_outlined, 'Colores lisos y oscuros',
          'Los tonos sólidos y las líneas verticales estilizan la figura.'));
    default:
      t.add(const Tip(Icons.checkroom, 'Regular Fit es tu base segura',
          'Con tus proporciones casi cualquier corte te funciona: elegí por estilo.'));
  }

  if (p.estatura == 'baja') {
    t.add(const Tip(Icons.height, 'Cuidá el largo',
        'Remeras cortas, pantalones de tiro alto y camperas hasta la cadera te alargan. Buscá líneas Petite.'));
  } else if (p.estatura == 'alta') {
    t.add(const Tip(Icons.height, 'Aprovechá tu altura',
        'Abrigos largos y pantalones de pierna ancha te quedan muy bien. Revisá que el largo del talle te alcance.'));
  }

  if (p.cadera - p.pecho >= 8) {
    t.add(const Tip(Icons.pivot_table_chart_outlined, 'Pantalones de tiro alto',
        'Equilibran las proporciones y marcan la cintura. Probá cortes rectos o con ligera apertura.'));
  } else if (p.pecho - p.cadera >= 8) {
    t.add(const Tip(Icons.pivot_table_chart_outlined, 'Camperas y hombros',
        'Elegí hombros que no tiren y suavizá con pantalones de pierna ancha.'));
  }

  t.add(const Tip(Icons.info_outline, 'Los talles cambian entre marcas',
      'Por eso FitMatch compara tus medidas con la tabla de cada prenda y no con la letra del talle.'));
  return t;
}

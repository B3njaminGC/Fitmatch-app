import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'models.dart';

/// Maniquí gris 3D "falso": se dibuja con las medidas reales del perfil y
/// rota según [angle] (0 = frente, pi/2 = lateral, pi = espalda).
class MannequinPainter extends CustomPainter {
  MannequinPainter({
    required this.perfil,
    this.prod,
    this.talla,
    this.angle = 0,
    this.guias = false,
  });

  final Perfil perfil;
  final Producto? prod;
  final Talla? talla;
  final double angle;
  final bool guias;

  static const _skin = Color(0xFFC9CCD1);
  static const _skinDark = Color(0xFFA3A7AE);

  static Path _smooth(List<Offset> pts) {
    final n = pts.length;
    Offset mid(int i) => (pts[i % n] + pts[(i + 1) % n]) / 2;
    final path = Path()..moveTo(mid(0).dx, mid(0).dy);
    for (var i = 1; i <= n; i++) {
      final c = pts[i % n];
      final m = mid(i);
      path.quadraticBezierTo(c.dx, c.dy, m.dx, m.dy);
    }
    return path..close();
  }

  static Path _sym(double cx, List<List<double>> pts) {
    final left = [for (final q in pts) Offset(cx - q[0], q[1])];
    final right = [for (final q in pts.reversed) Offset(cx + q[0], q[1])];
    return _smooth([...left, ...right]);
  }

  static Paint _fill(Color base, Rect r) {
    final dark = Color.lerp(base, Colors.black, 0.16)!;
    return Paint()
      ..shader = LinearGradient(
        colors: [dark, base, dark],
        stops: const [0, 0.5, 1],
      ).createShader(r);
  }

  static Paint _line(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _draw(Canvas canvas, Path path, Color base) {
    canvas.drawPath(path, _fill(base, path.getBounds()));
    canvas.drawPath(
        path, _line(Color.lerp(base, Colors.black, 0.3)!.withAlpha(150), 0.8));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final p = perfil;
    final h = p.altura;
    final s = size.height * 0.93 / h; // píxeles por cm
    final top = size.height * 0.035;
    final cx = size.width / 2;
    final c = math.cos(angle).abs();
    final sn = math.sin(angle).abs();
    final front = math.cos(angle) >= 0;

    double y(double cm) => top + cm * s;
    double hw(double circ) => 0.5 * circ * (0.36 * c + 0.25 * sn) * s;

    // Alturas (cm desde la cabeza)
    final yNeck = h * 0.165;
    final yShoulder = h * 0.19;
    final yBust = h * 0.265;
    final yWaist = h * 0.385;
    final yHip = h * 0.50;
    final yCrotch = math.max(h - p.entrepierna, yHip + 5);
    final yKnee = yCrotch + (h - yCrotch) * 0.48;
    final yAnkle = h * 0.955;
    final yFloor = h;

    // Anchos del cuerpo (px, mitad)
    final shHalf = 0.5 * (p.pecho * 0.42 * c + p.pecho * 0.24 * sn) * s;
    final bustHalf = hw(p.pecho);
    final waistHalf = hw(p.cintura);
    final hipHalf = hw(p.cadera);
    final neckHalf = 5.4 * s;

    final thigh = p.cadera * 0.58;
    final knee = p.cadera * 0.40;
    final ankle = p.cadera * 0.26;
    final legOff = 0.09 * p.cadera * s * c;

    // Sombra de piso
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, y(yFloor)),
          width: size.width * 0.55,
          height: 9 * s),
      Paint()..color = Colors.black.withAlpha(22),
    );

    Path legPath(double lx, double e, double yEnd) {
      double lh(double circ) => 0.5 * circ * (0.32 * c + 0.30 * sn) * s + e;
      final t = lh(thigh), k = lh(knee), a = lh(ankle);
      final yt = y(yCrotch) - 8 * s;
      return _smooth([
        Offset(lx - t, yt),
        Offset(lx - k, y(yKnee)),
        Offset(lx - a, y(yEnd)),
        Offset(lx + a, y(yEnd)),
        Offset(lx + k, y(yKnee)),
        Offset(lx + t, yt),
      ]);
    }

    // ---- Prenda: medidas ----
    final garment = prod != null && talla != null;
    // Solo se leen cuando [garment] es true (acceso perezoso).
    late final Producto pr = prod!;
    late final Talla tl = talla!;
    final gcolor = garment ? Color(pr.color) : _skin;
    var gChest = 0.0, gWaist = 0.0, gHip = 0.0;
    if (garment) {
      final hol = pr.corte.holgura;
      switch (pr.tipo) {
        case Tipo.remera:
        case Tipo.campera:
          gChest = math.max((tl.lo + tl.hi) / 2 + hol, p.pecho + 1);
          double rW = (p.cintura / p.pecho).clamp(0.75, 1.0).toDouble();
          rW = rW + (1 - rW) * pr.corte.boxy;
          gWaist = math.max(gChest * rW, p.cintura + 1);
          double rH = (p.cadera / p.cintura).clamp(1.0, 1.3).toDouble();
          rH = 1 + (rH - 1) * (1 - pr.corte.boxy);
          gHip = math.max(gWaist * rH, p.cadera + 1);
        case Tipo.vestido:
          gChest = math.max((tl.lo + tl.hi) / 2 + hol * 0.5, p.pecho + 1);
          gWaist = math.max(
              (tl.cinLo! + tl.cinHi!) / 2 + hol * 0.5, p.cintura + 1);
          gHip = math.max(
              (tl.cadLo! + tl.cadHi!) / 2 + hol * 0.6, p.cadera + 1);
        case Tipo.pantalon:
          gWaist = math.max((tl.lo + tl.hi) / 2 + hol * 0.5, p.cintura + 1);
          gHip = math.max(
              (tl.cadLo! + tl.cadHi!) / 2 + hol * 0.8, p.cadera + 1);
      }
    }
    final esPantalon = garment && pr.tipo == Tipo.pantalon;
    final esUpper = garment && !esPantalon;

    // 1) Piernas (piel)
    final yLegEnd = yFloor - 3;
    _draw(canvas, legPath(cx - legOff, 0, yLegEnd), _skin);
    _draw(canvas, legPath(cx + legOff, 0, yLegEnd), _skin);
    final footRx = hw(p.cadera) * 0.22 + 3 * s + 5 * s * sn;
    for (final sg in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx + sg * legOff + 4 * s * sn, y(yFloor) - 1.5 * s),
            width: footRx * 2,
            height: 4.4 * s),
        Paint()..color = _skinDark,
      );
    }

    // 2) Pantalón (piernas)
    if (esPantalon) {
      final e = math.max(0.6 * s,
          ((gHip - p.cadera) * 0.12 + pr.corte.holgura * 0.1) * s);
      final yHem = math.min(yCrotch + tl.largo, yFloor - 1.5);
      _draw(canvas, legPath(cx - legOff, e, yHem), gcolor);
      _draw(canvas, legPath(cx + legOff, e, yHem), gcolor);
    }

    // 3) Torso (piel)
    final torso = _sym(cx, [
      [neckHalf, y(yNeck)],
      [shHalf, y(yShoulder)],
      [bustHalf, y(yBust)],
      [waistHalf, y(yWaist)],
      [hipHalf, y(yHip)],
      [hipHalf * 0.97, y(yCrotch) + 2 * s],
    ]);
    _draw(canvas, torso, _skin);

    // 4) Pantalón (cintura/cadera)
    if (esPantalon) {
      final yWp = h * 0.405;
      final lower = _sym(cx, [
        [hw(gWaist), y(yWp)],
        [hw(gHip), y(yHip)],
        [hw(gHip) * 0.98, y(yCrotch) + 3 * s],
      ]);
      _draw(canvas, lower, gcolor);
      final band = _line(Color.lerp(gcolor, Colors.black, 0.35)!, 1.2);
      canvas.drawLine(Offset(cx - hw(gWaist), y(yWp)),
          Offset(cx + hw(gWaist), y(yWp)), band);
      if (front && c > 0.3) {
        canvas.drawLine(Offset(cx, y(yWp)), Offset(cx, y(yCrotch)), band);
      }
    }

    // 5) Cuello y cabeza
    canvas.drawLine(
      Offset(cx, y(h * 0.12)),
      Offset(cx, y(yNeck) + 1 * s),
      _line(_skin, neckHalf * 2),
    );
    final ry = h * 0.065 * s;
    final headRect = Rect.fromCenter(
        center: Offset(cx, y(h * 0.065)),
        width: ry * 2 * (0.78 * c + 0.95 * sn),
        height: ry * 2);
    canvas.drawOval(headRect, _fill(_skin, headRect));
    canvas.drawOval(headRect, _line(_skinDark, 0.8));

    // 6) Prenda superior
    double yHemU = 0;
    if (esUpper) {
      final vest = pr.tipo == Tipo.vestido;
      yHemU = math.min(yShoulder + tl.largo, yAnkle);
      final hemHalf = vest ? hw(gHip) * 1.12 : hw(gHip);
      final upper = _sym(cx, [
        [neckHalf * 1.15, y(yNeck)],
        [shHalf + 1.5 * s, y(yShoulder)],
        [hw(gChest), y(yBust)],
        [hw(gWaist), y(yWaist)],
        if (yHemU > yHip + 2) [hw(gHip), y(yHip)],
        [hemHalf, y(yHemU)],
      ]);
      _draw(canvas, upper, gcolor);
      final detail = _line(Color.lerp(gcolor, Colors.black, 0.35)!, 1.1);
      if (front && c > 0.3) {
        if (pr.tipo == Tipo.campera) {
          canvas.drawLine(
              Offset(cx, y(yNeck)), Offset(cx, y(yHemU)), detail);
        } else {
          canvas.drawArc(
            Rect.fromCenter(
                center: Offset(cx, y(yNeck) + 0.5 * s),
                width: neckHalf * 2.1,
                height: 6 * s),
            0,
            math.pi,
            false,
            detail,
          );
        }
      }
    }

    // 7) Brazos (piel)
    final armHalf = p.pecho * 0.052 * s;
    final ax0 = (0.5 * p.pecho * 0.42 * s - armHalf * 0.6) * c;
    final ax1 = (0.5 * p.cadera * 0.36 * s + armHalf * 0.9) * c;
    final armLen = h * 0.40;
    Offset a0(double sg) => Offset(cx + sg * ax0, y(yShoulder) + armHalf * 0.5);
    Offset a1(double sg) => Offset(cx + sg * ax1, y(yShoulder + armLen));
    for (final sg in [-1.0, 1.0]) {
      canvas.drawLine(a0(sg), a1(sg), _line(_skin, armHalf * 1.7));
    }

    // 8) Mangas
    if (esUpper && pr.tipo != Tipo.vestido) {
      final largas = pr.tipo == Tipo.campera;
      final ease = (pr.corte.holgura * 0.12 + 0.5) * s;
      for (final sg in [-1.0, 1.0]) {
        final end = Offset.lerp(a0(sg), a1(sg), largas ? 0.93 : 0.36)!;
        canvas.drawLine(
          a0(sg),
          end,
          _line(Color.lerp(gcolor, Colors.black, 0.08)!, (armHalf + ease) * 2),
        );
      }
    }

    // Guías de medidas
    if (guias) {
      void guia(String txt, double yy, double halfPx) {
        final paint = _line(const Color(0xFF7F77DD), 1);
        var x = 6.0;
        while (x < cx - halfPx - 4) {
          canvas.drawLine(Offset(x, yy), Offset(math.min(x + 4, cx - halfPx - 4), yy), paint);
          x += 8;
        }
        final tp = TextPainter(
          text: TextSpan(
              text: txt,
              style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF534AB7),
                  fontWeight: FontWeight.w600)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(6, yy - 13));
      }

      guia('Pecho ${p.pecho.round()}', y(yBust), bustHalf);
      guia('Cintura ${p.cintura.round()}', y(yWaist), waistHalf);
      guia('Cadera ${p.cadera.round()}', y(yHip), hipHalf);
    }
  }

  @override
  bool shouldRepaint(covariant MannequinPainter old) => true;
}

import 'package:flutter/material.dart';

import 'theme.dart';

/// Die beiden Ticks (▲ grün, ▼ rot) in der kanonischen Proportion:
/// je 0,40 × 0,347 em, Abstand 0,20 em (em = Schriftgröße der Wortmarke).
class Ticks extends StatelessWidget {
  const Ticks({super.key, required this.em});
  final double em;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: em * 1.0,
        height: em * 0.347,
        child: CustomPaint(painter: _TickMaler()),
      );
}

class _TickMaler extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final em = size.width; // Breite = 0,40 + 0,20 + 0,40 em
    final w = 0.40 * em, h = size.height, gap = 0.20 * em;
    final auf = Path()
      ..moveTo(0, h)
      ..lineTo(w, h)
      ..lineTo(w / 2, 0)
      ..close();
    final ab = Path()
      ..moveTo(w + gap, 0)
      ..lineTo(2 * w + gap, 0)
      ..lineTo(w + gap + w / 2, h)
      ..close();
    canvas.drawPath(auf, Paint()..color = KZ.gruen);
    canvas.drawPath(ab, Paint()..color = KZ.rot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Kopfzeilen-Form: Ticks links neben der Wortmarke (einzige zugelassene Abweichung, nur für Kopfzeilen).
class LogoZeile extends StatelessWidget {
  const LogoZeile({super.key, this.groesse = 24});
  final double groesse;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(padding: EdgeInsets.only(bottom: groesse * 0.08), child: Ticks(em: groesse)),
          SizedBox(width: groesse * 0.173),
          Text('Kurszettel',
              style: TextStyle(
                  fontFamily: KZ.caslon, fontWeight: FontWeight.w700, fontSize: groesse, height: 1, letterSpacing: -0.01 * groesse, color: KZ.creme)),
        ],
      );
}

/// Logoblock: Ticks mittig über der Wortmarke, Haarlinie, Untertitel.
class LogoBlock extends StatelessWidget {
  const LogoBlock({super.key, this.groesse = 44, this.untertitel = true});
  final double groesse;
  final bool untertitel;

  @override
  Widget build(BuildContext context) {
    final f = groesse;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Ticks(em: f),
        SizedBox(height: f * 0.173),
        Text('Kurszettel',
            style: TextStyle(fontFamily: KZ.caslon, fontWeight: FontWeight.w700, fontSize: f, height: 1, letterSpacing: -0.01 * f, color: KZ.creme)),
        if (untertitel) ...[
          SizedBox(height: f * 0.22),
          Container(width: f * 3.47, height: 1, color: KZ.creme.withValues(alpha: 0.35)),
          SizedBox(height: f * 0.18),
          Text('WAS GELD BEWEGT. JEDEN HANDELSTAG.',
              style: TextStyle(fontFamily: KZ.mono, fontSize: f * 0.20, letterSpacing: f * 0.20 * 0.15, color: KZ.creme.withValues(alpha: 0.9))),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';

/// The WorkPulse mark (pulse line ending in the live dot), drawn in code so
/// it stays sharp at any size and needs no SVG dependency.
///
/// Geometry matches the launcher icon: a 1024-unit design grid.
class WpLogoMark extends StatelessWidget {
  const WpLogoMark({
    super.key,
    this.size = 28,
    this.color = const Color(0xFF3DD6B0),
    this.semanticLabel = 'WorkPulse',
  });

  final double size;
  final Color color;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _PulsePainter(color)),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter(this.color);

  final Color color;

  // Mark bounds on the design grid: x 236..821, y 270..730.
  static const double _minX = 236, _maxX = 821, _minY = 270, _maxY = 730;

  @override
  void paint(Canvas canvas, Size size) {
    const w = _maxX - _minX, h = _maxY - _minY;
    final s = size.width / w;
    canvas
      ..save()
      ..translate(0, (size.height - h * s) / 2)
      ..scale(s)
      ..translate(-_minX, -_minY);

    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 52
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(262, 530)
      ..lineTo(392, 530)
      ..lineTo(452, 300)
      ..lineTo(532, 700)
      ..lineTo(592, 460)
      ..lineTo(632, 530)
      ..lineTo(742, 530);
    canvas.drawPath(path, line);

    const dot = Offset(742, 530);
    canvas.drawCircle(
      dot,
      72,
      Paint()
        ..color = color.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14,
    );
    canvas.drawCircle(dot, 40, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PulsePainter old) => old.color != color;
}

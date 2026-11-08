import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A bordered tappable card.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
    this.color,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return Material(
      color: color ?? Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// The WorkPulse heartbeat mark.
class PulseMark extends StatelessWidget {
  const PulseMark({this.size = 28, super.key});

  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: const _PulsePainter());
}

class _PulsePainter extends CustomPainter {
  const _PulsePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 24;
    final points = <Offset>[
      const Offset(2, 12),
      const Offset(6, 12),
      const Offset(8.5, 6),
      const Offset(12.5, 18),
      const Offset(15.5, 9),
      const Offset(17.5, 12),
      const Offset(22, 12),
    ].map((p) => p * unit).toList();
    final path = Path()..addPolygon(points, false);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8 * unit
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_PulsePainter oldDelegate) => false;
}

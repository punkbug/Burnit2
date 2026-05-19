import 'package:flutter/material.dart';

class FlameIllustration extends StatelessWidget {
  const FlameIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.25,
      child: CustomPaint(
        painter: _FlamePainter(),
      ),
    );
  }
}

class _FlamePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2);

    // Soft arcs in the background (keep the same calm vibe).
    final Paint arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.12);
    for (int i = 0; i < 4; i++) {
      final double r = size.width * (0.38 + i * 0.10);
      final Rect rect = Rect.fromCircle(center: Offset(c.dx, size.height * 0.70), radius: r);
      canvas.drawArc(rect, 3.14, 3.14, false, arc);
    }

    // Clouds.
    final Paint cloud = Paint()..color = Colors.white.withValues(alpha: 0.22);
    _cloud(canvas, cloud, Offset(size.width * 0.18, size.height * 0.62), size.width * 0.18);
    _cloud(canvas, cloud, Offset(size.width * 0.82, size.height * 0.60), size.width * 0.16);

    // Flame base shadow.
    final Paint shadow = Paint()..color = const Color(0xFF2E3440).withValues(alpha: 0.14);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.50, size.height * 0.78),
        width: size.width * 0.44,
        height: size.height * 0.10,
      ),
      shadow,
    );

    // Flame (outer).
    final Paint outer = Paint()..color = const Color(0xFFFFE1B8);
    final Path outerPath = Path()
      ..moveTo(size.width * 0.50, size.height * 0.22)
      ..cubicTo(
        size.width * 0.62,
        size.height * 0.30,
        size.width * 0.72,
        size.height * 0.44,
        size.width * 0.66,
        size.height * 0.60,
      )
      ..cubicTo(
        size.width * 0.62,
        size.height * 0.72,
        size.width * 0.52,
        size.height * 0.82,
        size.width * 0.50,
        size.height * 0.84,
      )
      ..cubicTo(
        size.width * 0.48,
        size.height * 0.82,
        size.width * 0.38,
        size.height * 0.72,
        size.width * 0.34,
        size.height * 0.60,
      )
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.44,
        size.width * 0.38,
        size.height * 0.30,
        size.width * 0.50,
        size.height * 0.22,
      )
      ..close();
    canvas.drawPath(outerPath, outer);

    // Flame (mid).
    final Paint mid = Paint()..color = const Color(0xFFFFC48D);
    final Path midPath = Path()
      ..moveTo(size.width * 0.50, size.height * 0.32)
      ..cubicTo(
        size.width * 0.58,
        size.height * 0.38,
        size.width * 0.64,
        size.height * 0.48,
        size.width * 0.60,
        size.height * 0.60,
      )
      ..cubicTo(
        size.width * 0.57,
        size.height * 0.69,
        size.width * 0.52,
        size.height * 0.74,
        size.width * 0.50,
        size.height * 0.76,
      )
      ..cubicTo(
        size.width * 0.48,
        size.height * 0.74,
        size.width * 0.43,
        size.height * 0.69,
        size.width * 0.40,
        size.height * 0.60,
      )
      ..cubicTo(
        size.width * 0.36,
        size.height * 0.48,
        size.width * 0.42,
        size.height * 0.38,
        size.width * 0.50,
        size.height * 0.32,
      )
      ..close();
    canvas.drawPath(midPath, mid);

    // Flame (inner).
    final Paint inner = Paint()..color = const Color(0xFFFFF3D8);
    final Path innerPath = Path()
      ..moveTo(size.width * 0.50, size.height * 0.42)
      ..cubicTo(
        size.width * 0.55,
        size.height * 0.47,
        size.width * 0.58,
        size.height * 0.53,
        size.width * 0.55,
        size.height * 0.61,
      )
      ..cubicTo(
        size.width * 0.53,
        size.height * 0.66,
        size.width * 0.51,
        size.height * 0.68,
        size.width * 0.50,
        size.height * 0.70,
      )
      ..cubicTo(
        size.width * 0.49,
        size.height * 0.68,
        size.width * 0.47,
        size.height * 0.66,
        size.width * 0.45,
        size.height * 0.61,
      )
      ..cubicTo(
        size.width * 0.42,
        size.height * 0.53,
        size.width * 0.45,
        size.height * 0.47,
        size.width * 0.50,
        size.height * 0.42,
      )
      ..close();
    canvas.drawPath(innerPath, inner);

    // Small "sparks".
    final Paint spark = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.30);
    for (int i = 0; i < 10; i++) {
      final double dx = (i.isEven ? -1 : 1) * (size.width * (0.06 + i * 0.01));
      final double dy = size.height * (0.10 + i * 0.03);
      canvas.drawCircle(Offset(c.dx + dx, dy), (2.4 - i * 0.12).clamp(1.2, 2.4), spark);
    }
  }

  void _cloud(Canvas canvas, Paint paint, Offset center, double width) {
    final double h = width * 0.44;
    final RRect base = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx, center.dy + h * 0.10), width: width, height: h),
      Radius.circular(h / 2),
    );
    canvas.drawRRect(base, paint);
    canvas.drawCircle(Offset(center.dx - width * 0.22, center.dy - h * 0.04), h * 0.42, paint);
    canvas.drawCircle(Offset(center.dx + width * 0.04, center.dy - h * 0.20), h * 0.50, paint);
    canvas.drawCircle(Offset(center.dx + width * 0.28, center.dy - h * 0.04), h * 0.38, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


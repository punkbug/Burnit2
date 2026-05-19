import 'package:flutter/material.dart';

class MeditationIllustration extends StatelessWidget {
  const MeditationIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.25,
      child: CustomPaint(
        painter: _MeditationPainter(),
      ),
    );
  }
}

class _MeditationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2);

    // Soft arcs in the background.
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

    // Person: base colors.
    final Paint skin = Paint()..color = const Color(0xFFF6C7A6);
    final Paint hair = Paint()..color = const Color(0xFF2E3440);
    final Paint shirt = Paint()..color = const Color(0xFFFFF2D9);
    final Paint pants = Paint()..color = const Color(0xFF3B4252);

    // Head.
    final Offset head = Offset(size.width * 0.50, size.height * 0.36);
    canvas.drawCircle(head, size.width * 0.06, skin);
    canvas.drawCircle(Offset(head.dx, head.dy - size.width * 0.012), size.width * 0.06, hair);
    canvas.drawCircle(Offset(head.dx, head.dy + size.width * 0.008), size.width * 0.056, skin);

    // Body (shirt).
    final Rect torso = Rect.fromCenter(
      center: Offset(size.width * 0.50, size.height * 0.50),
      width: size.width * 0.22,
      height: size.height * 0.22,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(torso, Radius.circular(size.width * 0.08)), shirt);

    // Arms (praying hands).
    final Paint arm = Paint()..color = shirt.color;
    final Path leftArm = Path()
      ..moveTo(size.width * 0.44, size.height * 0.48)
      ..quadraticBezierTo(size.width * 0.41, size.height * 0.56, size.width * 0.47, size.height * 0.60)
      ..quadraticBezierTo(size.width * 0.49, size.height * 0.57, size.width * 0.50, size.height * 0.54)
      ..close();
    canvas.drawPath(leftArm, arm);
    final Path rightArm = Path()
      ..moveTo(size.width * 0.56, size.height * 0.48)
      ..quadraticBezierTo(size.width * 0.59, size.height * 0.56, size.width * 0.53, size.height * 0.60)
      ..quadraticBezierTo(size.width * 0.51, size.height * 0.57, size.width * 0.50, size.height * 0.54)
      ..close();
    canvas.drawPath(rightArm, arm);

    // Hands.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.50, size.height * 0.57),
          width: size.width * 0.03,
          height: size.height * 0.06,
        ),
        Radius.circular(size.width * 0.02),
      ),
      skin,
    );

    // Legs crossed.
    final Rect leftLeg = Rect.fromCenter(
      center: Offset(size.width * 0.40, size.height * 0.69),
      width: size.width * 0.40,
      height: size.height * 0.12,
    );
    final Rect rightLeg = Rect.fromCenter(
      center: Offset(size.width * 0.60, size.height * 0.69),
      width: size.width * 0.40,
      height: size.height * 0.12,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(leftLeg, Radius.circular(size.width * 0.08)), pants);
    canvas.drawRRect(RRect.fromRectAndRadius(rightLeg, Radius.circular(size.width * 0.08)), pants);

    // Feet.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.30, size.height * 0.70),
        width: size.width * 0.09,
        height: size.height * 0.04,
      ),
      skin,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.70, size.height * 0.70),
        width: size.width * 0.09,
        height: size.height * 0.04,
      ),
      skin,
    );

    // Small "birds" strokes.
    final Paint bird = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.25);
    _bird(canvas, bird, Offset(size.width * 0.72, size.height * 0.43), size.width * 0.04);
    _bird(canvas, bird, Offset(size.width * 0.77, size.height * 0.46), size.width * 0.032);
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

  void _bird(Canvas canvas, Paint paint, Offset center, double r) {
    final Path path = Path()
      ..moveTo(center.dx - r, center.dy)
      ..quadraticBezierTo(center.dx - r * 0.35, center.dy - r * 0.45, center.dx, center.dy)
      ..quadraticBezierTo(center.dx + r * 0.35, center.dy - r * 0.45, center.dx + r, center.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

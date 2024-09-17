import 'package:flutter/material.dart';

class InitialsAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color backgroundColor;
  final Color textColor;

  InitialsAvatar({
    required this.initials,
    this.size = 50.0,
    this.backgroundColor = Colors.deepPurple,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _InitialsPainter(initials, backgroundColor, textColor),
    );
  }
}

class _InitialsPainter extends CustomPainter {
  final String initials;
  final Color backgroundColor;
  final Color textColor;

  _InitialsPainter(this.initials, this.backgroundColor, this.textColor);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = backgroundColor;
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Radius radius = Radius.circular(size.width / 2);

    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);

    final textStyle = TextStyle(
      color: textColor,
      fontSize: size.width / 2,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: initials,
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

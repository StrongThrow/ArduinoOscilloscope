import 'package:flutter/material.dart';

class MacOSBar extends StatelessWidget {
  final double height;
  final Color color;

  const MacOSBar({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color,
      ),
      child: Row(
        children: [
          CustomPaint(
            size: Size(12, 12),
            painter: MacOSButtonPainter(color: Colors.red),
          ),
          SizedBox(width: 8),
          CustomPaint(
            size: Size(12, 12),
            painter: MacOSButtonPainter(color: Colors.yellow),
          ),
          SizedBox(width: 8),
          CustomPaint(
            size: Size(12, 12),
            painter: MacOSButtonPainter(color: Colors.green),
          ),
        ],
      ),
    );
  }
}

class MacOSButtonPainter extends CustomPainter {
  final Color color;

  MacOSButtonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
import 'dart:ui';

import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> samples;

  WaveformPainter(this.samples);

  @override
  void paint(Canvas canvas, Size size) {
    final waveformPaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    Path createDashedPath(Path originalPath, double dashWidth, double gapWidth) {
      final dashedPath = Path();
      bool shouldDraw = true;
      for (PathMetric pathMetric in originalPath.computeMetrics()) {
        double distance = 0.0;
        while (distance < pathMetric.length) {
          final nextDistance = distance + (shouldDraw ? dashWidth : gapWidth);
          final pathSegment = pathMetric.extractPath(
            distance,
            nextDistance.clamp(0.0, pathMetric.length),
          );
          if (shouldDraw) {
            dashedPath.addPath(pathSegment, Offset.zero);
          }
          distance = nextDistance;
          shouldDraw = !shouldDraw;
        }
      }
      return dashedPath;
    }

    // 점선 0V, 2.5V, 5V
    final yValues = [0.0, 0.5, 1.0];
    final labels = ['0V', '2.5V', '5V'];

    for (int i = 0; i < yValues.length; i++) {
      final y = size.height - (yValues[i] * size.height);
      final path = Path()..moveTo(0, y)..lineTo(size.width, y);
      final dashedPath = createDashedPath(path, 5.0, 5.0); // 점선
      canvas.drawPath(dashedPath, gridPaint);

      // 라벨 (0V, 2.5V, 5V)
      final textSpan = TextSpan(
        text: labels[i],
        style: TextStyle(color: Colors.grey, fontSize: 10),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }

    for (int i = 1; i <= 4; i++) {
      final x = (i / 4) * size.width;
      final path = Path()..moveTo(x, 0)..lineTo(x, size.height);
      final dashedPath = createDashedPath(path, 5.0, 5.0);
      canvas.drawPath(dashedPath, gridPaint);
    }

    final path = Path();
    final width = size.width;
    final height = size.height;
    final middleY = height;

    for (int i = 0; i < samples.length; i++) {
      final x = i / samples.length * width;
      final y = middleY - samples[i] * middleY;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, waveformPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
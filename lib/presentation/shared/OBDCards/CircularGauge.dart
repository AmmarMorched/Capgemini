import 'dart:math';
import 'package:flutter/material.dart';

class CircularGauge extends StatelessWidget {
  /// Current value (e.g. speed)
  final double value;

  /// Minimum and maximum gauge range
  final double min;
  final double max;

  /// Segments: list of (endValue, color)
  final List<GaugeSegment> segments;

  /// Size of the gauge
  final double size;

  /// Center icon
  final IconData centerIcon;

  /// Center label
  final String centerLabel;

  const CircularGauge({
    Key? key,
    required this.value,
    this.min = 0,
    this.max = 100,
    required this.segments,
    this.size = 200,
    this.centerIcon = Icons.speed,
    this.centerLabel = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GaugePainter(
          value: value,
          min: min,
          max: max,
          segments: segments,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(centerIcon, size: size * 0.15, color: Colors.white70),
              if (centerLabel.isNotEmpty) ...[
                SizedBox(height: size * 0.02),
                Text(
                  centerLabel,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class GaugeSegment {
  final double endValue;
  final Color color;
  GaugeSegment(this.endValue, this.color);
}

class _GaugePainter extends CustomPainter {
  final double value, min, max;
  final List<GaugeSegment> segments;

  _GaugePainter({
    required this.value,
    required this.min,
    required this.max,
    required this.segments,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final strokeWidth = radius * 0.12;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
    final startAngle = 3 * pi / 4; // 135°
    final sweepAngleTotal = 3 * pi / 2; // 270°

    // Draw background arc
    final bgPaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, startAngle, sweepAngleTotal, false, bgPaint);

    // Draw each colored segment
    double lastAngle = 0;
    for (var seg in segments) {
      final segmentSweep = sweepAngleTotal * ((seg.endValue - min) / (max - min)) - lastAngle;
      final segPaint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect, startAngle + lastAngle, segmentSweep, false, segPaint);
      lastAngle += segmentSweep;
    }

    // Draw value indicator (a thin pointer)
    final valueAngle = startAngle + sweepAngleTotal * ((value.clamp(min, max) - min) / (max - min));
    final pointerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    final pointerLength = radius - strokeWidth * 0.8;
    final pointerEnd = center +
        Offset(cos(valueAngle), sin(valueAngle)) * pointerLength;
    canvas.drawLine(center, pointerEnd, pointerPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) {
    return old.value != value || old.segments != segments;
  }
}

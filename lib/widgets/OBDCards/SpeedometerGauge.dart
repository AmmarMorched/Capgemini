import 'package:flutter/material.dart';
import 'dart:math';

class SpeedometerGauge extends StatefulWidget {
  final double currentSpeed;
  final double maxSpeed;
  final Color needleColor;
  final Color gaugeColor;
  final Color textColor;
  final double size;

  const SpeedometerGauge({
    super.key,
    required this.currentSpeed,
    this.maxSpeed = 180,
    this.needleColor = Colors.red,
    this.gaugeColor = Colors.blue,
    this.textColor = Colors.black,
    this.size = 300,
  });

  @override
  State<SpeedometerGauge> createState() => _SpeedometerGaugeState();
}

class _SpeedometerGaugeState extends State<SpeedometerGauge> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: SpeedometerPainter(
          currentSpeed: widget.currentSpeed,
          maxSpeed: widget.maxSpeed,
          needleColor: widget.needleColor,
          gaugeColor: widget.gaugeColor,
          textColor: widget.textColor,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.currentSpeed.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: widget.size * 0.15,
                  fontWeight: FontWeight.bold,
                  color: widget.textColor,
                ),
              ),
              Text(
                'km/h',
                style: TextStyle(
                  fontSize: widget.size * 0.06,
                  color: widget.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SpeedometerPainter extends CustomPainter {
  final double currentSpeed;
  final double maxSpeed;
  final Color needleColor;
  final Color gaugeColor;
  final Color textColor;

  SpeedometerPainter({
    required this.currentSpeed,
    required this.maxSpeed,
    required this.needleColor,
    required this.gaugeColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw the gauge background
    final gaugePaint = Paint()
      ..color = gaugeColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.1;

    canvas.drawCircle(center, radius * 0.9, gaugePaint);

    // Draw the gauge arc
    final arcPaint = Paint()
      ..color = gaugeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.08
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 240 * (currentSpeed / maxSpeed);
    final startAngle = -210 * (pi / 180);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.9),
      startAngle,
      sweepAngle * (pi / 180),
      false,
      arcPaint,
    );

    // Draw the needle
    final needleAngle = -210 + (240 * (currentSpeed / maxSpeed));
    final needlePaint = Paint()
      ..color = needleColor
      ..style = PaintingStyle.fill;

    final needlePath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(
        center.dx + radius * 0.6 * cos(needleAngle * pi / 180),
        center.dy + radius * 0.6 * sin(needleAngle * pi / 180),
      )
      ..lineTo(
        center.dx + radius * 0.1 * cos((needleAngle + 90) * pi / 180),
        center.dy + radius * 0.1 * sin((needleAngle + 90) * pi / 180),
      )
      ..close();

    canvas.drawPath(needlePath, needlePaint);

    // Draw center circle
    final centerPaint = Paint()
      ..color = needleColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.05, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
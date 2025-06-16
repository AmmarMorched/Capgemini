import 'package:flutter/material.dart';
class SpeedGauge extends StatelessWidget {
  final double speed;

  const SpeedGauge({super.key, required this.speed});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "${speed.toStringAsFixed(1)} km/h",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Fuel consumption",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
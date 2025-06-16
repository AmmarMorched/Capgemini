import 'package:flutter/material.dart';
class FuelLevelCard extends StatelessWidget {
  final double fuelLevel;

  const FuelLevelCard({super.key, required this.fuelLevel});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.local_gas_station),
            SizedBox(width: 8),
            Text(
              "Fuel",
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            Text(
              "${fuelLevel.toStringAsFixed(1)}%",
              style: TextStyle(fontSize: 16),
            ),
            Icon(Icons.battery_charging_full),
          ],
        ),
      ),
    );
  }
}
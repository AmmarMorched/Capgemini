import 'dart:async';
import 'dart:math';

class MockOBDData {
  final StreamController<double> _rpmStreamController = StreamController<double>.broadcast();
  final StreamController<double> _speedStreamController = StreamController<double>.broadcast();

  Stream<double> get rpmStream => _rpmStreamController.stream;
  Stream<double> get speedStream => _speedStreamController.stream;

  // Simulate live RPM data between 500 - 8000
  void startMockRPMUpdates() {
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      double randomRPM = _randomBetween(500.0, 8000.0);
      _rpmStreamController.add(randomRPM);
    });
  }

  void startMockSpeedUpdates() {
    Timer.periodic(Duration(milliseconds: 1000), (timer) {
      double randomSpeed = _randomBetween(0.0, 240.0);
      _speedStreamController.add(randomSpeed);
    });
  }

  double _randomBetween(double min, double max) {
    return min + (max - min) * _random.nextDouble();
  }

  final _random = Random();
}
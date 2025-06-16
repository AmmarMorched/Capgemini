// lib/entities/DriverBehaviorModel.dart

import 'dart:core';

/// A DriverBehaviorModel that penalizes the score only once per “rising edge”
/// of each unsafe event. It computes acceleration in km/h per second from
/// consecutive data points, and expects:
///   • 'timestamp': DateTime
///   • 'vehicle_speed': double (km/h)
///   • 'engine_rpm': double (rpm)
///   • 'throttle_position': double (0.0–1.0)
///   • 'coolant_temp': double (°C)
class DriverBehavior {
  /// Starts at 100, and is clamped ≥ 0.
  double _score = 100.0;

  // A short history buffer to compute acceleration
  final List<Map<String, dynamic>> _history = [];
  final int _maxHistoryLen = 5;

  // Track which events are currently “active” (so we only penalize once on rising edge)
  bool _isHarshAccelActive = false;
  bool _isHarshBrakeActive = false;
  bool _isOverSpeedActive = false;
  bool _isColdStartActive = false;

  // Log of all penalized events
  final List<Map<String, dynamic>> _eventLog = [];

  /// Public getter for the current score
  double get score => _score;

  /// Public getter for the full event log
  List<Map<String, dynamic>> get eventLog => List.unmodifiable(_eventLog);

  /// Feed one new data point into the model.
  ///
  /// dataPoint must contain:
  ///   'timestamp': DateTime,
  ///   'vehicle_speed': double (km/h),
  ///   'engine_rpm': double (rpm),
  ///   'throttle_position': double (0.0–1.0),
  ///   'coolant_temp': double (°C).
  void analyze(Map<String, dynamic> dataPoint) {
    // 1) Validate that all required fields exist
    if (!dataPoint.containsKey('timestamp') ||
        !dataPoint.containsKey('vehicle_speed') ||
        !dataPoint.containsKey('engine_rpm') ||
        !dataPoint.containsKey('throttle_position') ||
        !dataPoint.containsKey('coolant_temp')) {
      return;
    }

    final DateTime now = dataPoint['timestamp'] as DateTime;
    final double currSpeed = (dataPoint['vehicle_speed'] as num).toDouble();
    final double rpm = (dataPoint['engine_rpm'] as num).toDouble();
    final double throttle = (dataPoint['throttle_position'] as num).toDouble();
    final double coolant = (dataPoint['coolant_temp'] as num).toDouble();

    // 2) Append to history and trim if necessary
    _history.add(dataPoint);
    if (_history.length > _maxHistoryLen) {
      _history.removeAt(0);
    }

    // 3) Compute true acceleration (Δspeed / Δtime in seconds)
    double accelKmhPerSec = 0.0;
    if (_history.length > 1) {
      final prev = _history[_history.length - 2];
      final double prevSpeed = (prev['vehicle_speed'] as num).toDouble();
      final DateTime prevTime = prev['timestamp'] as DateTime;

      final double dtSec =
          now.difference(prevTime).inMilliseconds.toDouble() / 1000.0;
      if (dtSec > 0.0) {
        accelKmhPerSec = (currSpeed - prevSpeed) / dtSec;
      }
    }

    // 4a) Harsh Acceleration: throttle > 0.8, rpm > 4000, accel > +15 km/h/s
    final bool nowHarshAccel =
    (throttle > 0.8 && rpm > 4000.0 && accelKmhPerSec > 15.0);
    if (nowHarshAccel && !_isHarshAccelActive) {
      _penalize('Harsh Acceleration', 5.0, now);
      _isHarshAccelActive = true;
    }
    if (!nowHarshAccel) {
      _isHarshAccelActive = false;
    }

    // 4b) Harsh Braking: deceleration < -20 km/h/s
    final bool nowHarshBrake = (accelKmhPerSec < -20.0);
    if (nowHarshBrake && !_isHarshBrakeActive) {
      _penalize('Harsh Braking', 4.0, now);
      _isHarshBrakeActive = true;
    }
    if (!nowHarshBrake) {
      _isHarshBrakeActive = false;
    }

    // 4c) Over-Speeding: speed > 140 km/h
    final bool nowOverSpeed = (currSpeed > 140.0);
    if (nowOverSpeed && !_isOverSpeedActive) {
      _penalize('Over-Speeding', 3.0, now);
      _isOverSpeedActive = true;
    }
    if (!nowOverSpeed) {
      _isOverSpeedActive = false;
    }

    // 4d) Cold-Start Driving: coolant < 11°C AND speed > 50 km/h
    final bool nowColdStart = (coolant < 11.0 && currSpeed > 50.0);
    if (nowColdStart && !_isColdStartActive) {
      _penalize('Cold-Start Driving', 2.0, now);
      _isColdStartActive = true;
    }
    if (!nowColdStart) {
      _isColdStartActive = false;
    }
  }

  void _penalize(String eventName, double penalty, DateTime timestamp) {
    _score -= penalty;
    if (_score < 0.0) _score = 0.0;
    _eventLog.add({'timestamp': timestamp, 'event': eventName});
  }

  /// Returns a Map containing:
  ///   'score': current double score,
  ///   'events': List<Map<String, dynamic>> (all events so far)
  Map<String, dynamic> getResults() {
    return {
      'score': _score,
      'events': List<Map<String, dynamic>>.from(_eventLog),
    };
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../entities/DriverBehavior.dart';
import '../entities/OBDData.dart';
import 'ModeManager.dart';

class BehaviorService {
  final ModeManager _modeManager;
  final DriverBehavior _model = DriverBehavior();

  // Internal controllers:
  final StreamController<double> _scoreController =
  StreamController<double>.broadcast();
  final StreamController<String> _eventController =
  StreamController<String>.broadcast();

  StreamSubscription<OBDData>? _dataSub;

  BehaviorService(this._modeManager);

  /// Call this once (e.g. in initState of your main widget)
  void start() {
    // Ensure any previous subscription is cancelled
    _dataSub?.cancel();

    // Subscribe to real-time OBD data
    _dataSub = _modeManager.dataStream.listen(
      _onNewObdData,
      onError: (e) => debugPrint('BehaviorService: dataStream error: $e'),
      onDone: () => debugPrint('BehaviorService: dataStream closed'),
    );
  }

  /// Call this when you want to stop listening (e.g. dispose)
  void stop() {
    _dataSub?.cancel();
    _scoreController.close();
    _eventController.close();
  }

  /// Stream of the current driving score (emits a new value whenever it changes)
  Stream<double> get scoreStream => _scoreController.stream;

  /// Stream of detected event names (each time the model logs one, we emit it here)
  Stream<String> get eventStream => _eventController.stream;

  void _onNewObdData(OBDData data) {
    // 1) Build the dataPoint map exactly as the model expects.
    final dataPoint = <String, dynamic>{
      'timestamp': data.timestamp ?? DateTime.now(),
      'vehicle_speed': data.speed ?? 0.0,
      'engine_rpm': data.rpm ?? 0.0,
      'throttle_position': data.throttlePos ?? 0.0,
      'coolant_temp': (data.coolantTemp != null)
          ? ((data.coolantTemp! + 40) / 255)
          : 0.0,
    };

    // 2) Let the model analyze:
    _model.analyze(dataPoint);

    // 3) Fetch results and guard against null/missing values:
    final results = _model.getResults();

    // Safely extract score (default to 0.0 if missing or null):
    double newScore = 0.0;
    final rawScore = results['score'];
    if (rawScore is num) {
      newScore = rawScore.toDouble();
    }
    _scoreController.add(newScore);

    // Safely extract events list (default to empty list if missing or not a list):
    final eventsRaw = results['events'];
    List<Map<String, dynamic>> allEvents = [];
    if (eventsRaw is List) {
      // If it’s a List<dynamic> of maps, cast each element to Map<String, dynamic>
      allEvents = eventsRaw
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    // 4) Emit any newly added events:
    if (_lastEmittedEventCount < allEvents.length) {
      for (int i = _lastEmittedEventCount; i < allEvents.length; i++) {
        final ev = allEvents[i];
        final String eventName = ev['event'] as String? ?? 'UnknownEvent';
        _eventController.add(eventName);
      }
      _lastEmittedEventCount = allEvents.length;
    }
  }


  int _lastEmittedEventCount = 0;
}
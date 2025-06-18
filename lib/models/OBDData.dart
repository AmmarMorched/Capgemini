// obd_data_model.dart

class OBDData {
  final String? vin;
  final double? speed;
  final double? rpm;
  final double? coolantTemp;
  final double? fuelLevel;
  final double? throttlePos;
  final List<String> dtcs;
  final DateTime timestamp;
  final List<String> pendingDtcs;
  final double? acceleration; // km/h²
  final String drivingState; // 'idle', 'accelerating', 'braking', etc.


  OBDData({
    this.vin,
    this.speed,
    this.rpm,
    this.coolantTemp,
    this.fuelLevel,
    this.throttlePos,
    this.dtcs = const [],
    required this.timestamp,
    this.pendingDtcs = const [],
    this.acceleration,
    this.drivingState = 'unknown',
  });

  OBDData copyWith({
    String? vin,
    double? speed,
    double? rpm,
    double? coolantTemp,
    double? fuelLevel,
    double ? throttlePos,
    List<String>? dtcs,
    List<String>? pendingDtcs,
    DateTime? timestamp,
    double? acceleration,
    String? drivingState,
  }) {
    return OBDData(
      vin: vin ?? this.vin,
      speed: speed ?? this.speed,
      rpm: rpm ?? this.rpm,
      coolantTemp: coolantTemp ?? this.coolantTemp,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      throttlePos: throttlePos ?? this.throttlePos,
      dtcs: dtcs ?? this.dtcs,
      pendingDtcs: pendingDtcs ?? this.pendingDtcs,
      timestamp: timestamp ?? this.timestamp,
      acceleration: acceleration ?? this.acceleration,
      drivingState: drivingState ?? this.drivingState,
    );
  }

  factory OBDData.fromMap(Map<String, dynamic> map) {
    return OBDData(
      vin: map['vin'],
      speed: map['speed']?.toDouble(),
      rpm: map['rpm']?.toDouble(),
      coolantTemp: map['coolant_temp']?.toDouble(),
      fuelLevel: map['fuel_level']?.toDouble(),
      throttlePos: map['throttle_pos']?.toDouble(),
      dtcs: List<String>.from(map['dtcs'] ?? []),
      pendingDtcs: List<String>.from(map['pending_dtcs'] ?? []),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vin': vin,
      'speed': speed,
      'rpm': rpm,
      'coolant_temp': coolantTemp,
      'fuel_level': fuelLevel,
      'throttle_pos': throttlePos,
      'dtcs': dtcs,
      'pending_dtcs': pendingDtcs,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}

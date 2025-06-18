import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/OBDData.dart';
import '../services/OBD_service.dart';
import '../services/ObdDiscovery.dart';

class OBDViewModel with ChangeNotifier {
  late final OBDService _obdService;
  final ObdDiscoveryService _discoveryService = ObdDiscoveryService();

  // Connection & Status
  bool _isConnected = false;
  String _statusMessage = 'Not connected';
  bool _isLoading = false;
  String? _error;

  // OBD Data
  OBDData _currentData = OBDData(timestamp: DateTime.now());

  OBDData get currentData => _currentData;
  List<String> _dtcs = [];
  Map<String, dynamic> _carDetails = {};
  String _vin = '';
  String? _discoveredIP;
  int _defaultPort = 35000;

  OBDViewModelWithDiscovery() {
    _isLoading = true;
    _statusMessage = 'Initializing...';
    notifyListeners();
  }

  Future<void> discoverAndConnect() async {
    _isLoading = true;
    _statusMessage = 'Discovering OBD device...';
    notifyListeners();

    try {
      _discoveredIP = await _discoveryService.discoverIp();
      if (_discoveredIP != null) {
        _obdService = OBDService(
          serverAddress: _discoveredIP!,
          serverPort: _defaultPort,
        );
        _setupListeners(); // Setup listeners after _obdService is initialized
        await connectToDevice();
      } else {
        _error = 'Could not find OBD device on network';
        _statusMessage = 'No OBD device found';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Discovery failed: $e';
      _statusMessage = 'Discovery failed';
      notifyListeners();
    }
  }

  void _setupListeners() {
    _obdService.dataStream.listen((data) {
      _currentData = data;
      notifyListeners();
    });

    _obdService.statusStream.listen((status) {
      _statusMessage = status;
      _isConnected = status.contains('Connected');
      notifyListeners();
    });

    _obdService.commandResponseStream.listen((response) {
      debugPrint('[CMD] Raw response received: $response');
    });
  }

  Future<void> connectToDevice() async {
    if (_discoveredIP == null) {
      _error = 'No device discovered yet';
      _statusMessage = 'No device discovered';
      _isConnected = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _statusMessage = 'Connecting to OBD device...';
    notifyListeners();

    try {
      await _obdService.initConnection();
      _isConnected = true;
      _statusMessage = 'Connected to OBD device';
    } catch (e) {
      _error = 'Connection failed: $e';
      _statusMessage = 'Connection failed';
      _isConnected = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> startReading() async {
    await _obdService.startMode1();
  }


  Future<void> clearDTCs() async {
    try {
      await _obdService.clearDTCs();
    } catch (e) {
      _error = "Failed to clear DTCs: $e";
      notifyListeners();
    }
  }

  Future<void> readDTCs() async {
    try {
      _dtcs = await _obdService.readDTCs();
      notifyListeners();
    } catch (e) {
      _error = "Failed to read DTCs: $e";
      notifyListeners();
    }
  }

  Future<void> getVehicleVIN() async {
    try {
      _vin = await _obdService.getVehicleVIN();
      if (_vin.isNotEmpty) {
        _carDetails = await _obdService.extractSelectedCarDetails(_vin);
      }
      notifyListeners();
    } catch (e) {
      _error = "Failed to fetch VIN: $e";
      notifyListeners();
    }
  }

  Future<void> getFreezeFrameForDTC(String dtc) async {
    try {
      final frameData = await _obdService.getFreezeFrameForDTC(dtc);
      debugPrint("Freeze Frame Data: $frameData");
    } catch (e) {
      _error = "Failed to get freeze frame: $e";
      notifyListeners();
    }
  }

  // Public getters for UI
  bool get isLoading => _isLoading;
  String get statusMessage => _statusMessage;
  bool get isConnected => _isConnected;
  List<String> get dtcs => _dtcs;
  String get vin => _vin;
  Map<String, dynamic> get carDetails => _carDetails;
  String? get error => _error;

  void resetError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _obdService.dispose();
    super.dispose();
  }
}
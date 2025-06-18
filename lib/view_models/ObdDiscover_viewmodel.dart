import 'package:flutter/material.dart';

import '../services/ObdDiscovery.dart';

class ObdDiscoveryViewModel extends ChangeNotifier {
  final ObdDiscoveryService _discoveryService = ObdDiscoveryService();

  String? _obdIpAddress;
  bool _isLoading = false;
  String? _error;

  String? get obdIpAddress => _obdIpAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> startDiscovery() async {
    _isLoading = true;
    _error = null;
    _obdIpAddress = null;
    notifyListeners();

    try {
      final ip = await _discoveryService.discoverIp();
      if (ip != null) {
        _obdIpAddress = ip;
      } else {
        _error = "No OBD device found";
      }
    } catch (e) {
      _error = "Discovery failed: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
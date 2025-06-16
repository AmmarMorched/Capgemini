import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../entities/OBDData.dart';


class ModeManager {
  final String serverAddress;
  final int serverPort;
  static const Duration commandTimeout = Duration(seconds: 2);
  static const Duration reconnectDelay = Duration(seconds: 3);
  Socket? _socket;
  bool _isConnected = false;
  bool _isDisposing = false;
  bool _isReconnecting = false;
  final StringBuffer _responseBuffer = StringBuffer();
  final StreamController<OBDData> _dataController = StreamController
      .broadcast();
  final StreamController<String> _statusController = StreamController
      .broadcast();
  final StreamController<String> _commandResponseController = StreamController
      .broadcast();
  OBDData _currentData = OBDData(timestamp: DateTime.now());
  bool _isMode1Active = false;
  bool _isMode3Active = false;
  bool _isMode4Active = false;
  bool _isMode7Active = false;

  bool get isMode7Active => _isMode7Active;
  List<String> _lastPendingDTCs = [];
  Timer? _mode1Timer;
  final List<String> _mode1Commands = ["0105", "010C", "010D",  "0111", "012F"];

  Stream<OBDData> get dataStream => _dataController.stream;

  Stream<String> get statusStream => _statusController.stream;

  Stream<String> get commandResponseStream => _commandResponseController.stream;

  bool get isConnected => _isConnected;

  bool get isReconnecting => _isReconnecting;

  bool get isMode1Active => _isMode1Active;
  bool get isMode3Active => _isMode3Active;
  bool get isMode4Active => _isMode4Active;

  ///////////////constructor////////////////
  ModeManager({
    required this.serverAddress,
    required this.serverPort,
  });
  ///////////////initConnection////////////////
  Future<void> initConnection() async {
    if (_isReconnecting || _isDisposing) return;
    try {
      _isReconnecting = true;
      _updateStatus('Connecting...');
      await _socket?.close();
      _socket =
      await Socket.connect(
          serverAddress,
          serverPort,
          timeout: commandTimeout)
        ..setOption(SocketOption.tcpNoDelay, true)
        ..listen(_handleIncomingData,
            onError: (error, stackTrace) =>
                _handleError('Socket error', error, stackTrace),
            onDone: _handleDisconnection
        );
      //await _sendCommandWithResponse('ATZ');
      _isConnected = true;
      _isReconnecting = false;
      _updateStatus('Connected');
      await getVehicleVIN();
    } catch (e, st) {
      _handleError('Connection failed', e, st);
    }
  }
  /////command sending & response handling/////
  void _logCommandLifecycle(String command, String stage, {String? extra}) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[CMD][$timestamp][$command] $stage${extra != null
        ? ' - $extra'
        : ''}');
  }
  ///////Mode1 /Mode3/Mode4/Mode7 commands////////

  Future<void> clearDTCs() async {
    await _stopOtherModes();
    final response = await _sendCommand('04');
    if (response.startsWith('43')) {
      _currentData = _currentData.copyWith(dtcs: []);
      _dataController.add(_currentData);
      await Future.delayed(const Duration(seconds: 1));
      await readDTCs();
    }
  }
  Future<void> startMode1() async {
    _commandQueue.add(() async {
      await _stopOtherModes();
      _isMode1Active = true;
      _mode1Timer?.cancel();
      _mode1Timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
        if (!_isMode1Active) timer.cancel();
        _commandQueue.add(() =>
            _sendCommand(_mode1Commands[timer.tick % _mode1Commands.length]));
        _processCommandQueue();
      });
    });
    _processCommandQueue();
  }
  Future<List<String>> readDTCs() async {
    await _stopOtherModes();
    final response = await _sendCommand('03');
    if (response.startsWith('43')) {
      final dtcs = _parseDTCResponse(response);
      _currentData = _currentData.copyWith(dtcs: dtcs);
      _dataController.add(_currentData);
      return dtcs;
    }
    return [];
  }
  Future<void> dispose() async {
    _isDisposing = true;
    _mode1Timer?.cancel();
    _mode7MonitorTimer?.cancel();
    await _socket?.close();
    await _dataController.close();
    await _statusController.close();
    await _commandResponseController.close();
  }

  bool _isWaitingForVINResponse = false;
  final StringBuffer _vinResponseBuffer = StringBuffer();

  Future<String> _sendCommand(String command) async {
    print('[DEBUG] Sending command: "$command"');
    if (!_isConnected) {
      debugPrint('[CMD] !!! NOT CONNECTED - Cannot send: $command');
      return '';
    }
    if(command =='0902'){
      _vinResponseBuffer.clear();
      _isWaitingForVINResponse = true;
    }
    debugPrint('[CMD] >>> SENDING: $command');
    final stopwatch = Stopwatch()
      ..start();
    try {
      _socket?.write('$command\r\n');
      debugPrint('[CMD] Write completed for $command');
      if (command == '0902') {
        final response = await _commandResponseController.stream
            .firstWhere((r) => r.contains('4902') || r == 'TIMEOUT')
            .timeout(Duration(seconds: 5), onTimeout: () => 'TIMEOUT');

        stopwatch.stop();
        debugPrint('[CMD] <<< RECEIVED for $command (${stopwatch.elapsedMilliseconds}ms): $response');
        return response;
      } else {
        final response = await _commandResponseController.stream
            .firstWhere((r) => r.isNotEmpty)
            .timeout(commandTimeout, onTimeout: () => 'TIMEOUT');

        stopwatch.stop();
        debugPrint('[CMD] <<< RECEIVED for $command (${stopwatch.elapsedMilliseconds}ms): $response');
        return response;
      }
    } catch (e) {
      stopwatch.stop();
      debugPrint('[CMD] !!! ERROR during $command (${stopwatch.elapsedMilliseconds}ms): $e');
      rethrow;
    } finally {
      _isWaitingForVINResponse = false;
    }
  }
  void _handleIncomingData(List<int> data) {
    final response = String.fromCharCodes(data).trim();
    debugPrint('[RAW DATA] $response'); // Log raw incoming data
    if(_isWaitingForVINResponse && response.contains('4902')) {
      _vinResponseBuffer.write(response);
      if (response.contains('>')) {
        final completeResponse = _responseBuffer.toString().trim();
        debugPrint('[COMPLETE RESPONSE] $completeResponse');
        _commandResponseController.add(completeResponse);
        _vinResponseBuffer.clear();
        _isWaitingForVINResponse = false;
        _processResponse(completeResponse);
        _responseBuffer.clear();
      }
      //Check for multi-frame responses (like VIN)
      else if (response.contains('\r') || response.contains('4902')) {
        // Process immediately for multi-frame responses
        _commandResponseController.add(response);
        _processResponse(response);
        return;
      }
    }
    _responseBuffer.write(response);

    if (response.contains('>')) {
      final completeResponse = _responseBuffer.toString().trim();
      debugPrint('[COMPLETE RESPONSE] $completeResponse');
      _commandResponseController.add(completeResponse);
      _processResponse(completeResponse);
      _responseBuffer.clear();
    }
  }

  void _processResponse(String response) {
    debugPrint('[PROCESSING RESPONSE] $response');
    try {
      if (response.startsWith('41')) {
        final data = _parseMode1Data(response);
        debugPrint('[PARSED DATA] $data');
        if (data.isNotEmpty) {
          _dataController.add(OBDData(
              speed: data['speed'],
              rpm: data['rpm'],
              coolantTemp: data['coolant_temp'],
              //fuelLevel: data['fuel_level'],
              throttlePos: data['throttle_pos'],
              timestamp: DateTime.now()
          ));
        }
      }
      else if (response.startsWith('43')) {
        final dtcs = _parseDTCResponse(response);
        _currentData = _currentData.copyWith(dtcs: dtcs);
        _dataController.add(_currentData); // Emit the updated data
      }
      else if (response.startsWith('47')) {
        final pendingDtcs = _parseDTCResponse(
            response.replaceFirst('47', '43'));
        if (pendingDtcs.isNotEmpty &&
            !_listEquals(_lastPendingDTCs, pendingDtcs)) {
          _lastPendingDTCs = List.from(pendingDtcs);
        }
        _currentData = _currentData.copyWith(pendingDtcs: pendingDtcs);
        _dataController.add(_currentData);
      }
    } catch (e, st) {
      debugPrint('Parse error: $e\n$st');
    }
  }
  Map<String, double> _parseMode1Data(String response) {
    final cleaned = response.replaceAll(' ', '');
    final parts = [
      for (int i = 0; i + 1 < cleaned.length; i += 2)
        cleaned.substring(i, i + 2)
    ];
    debugPrint('[PARSE MODE 1] Cleaned: $cleaned');
    debugPrint('[PARSE MODE 1] Parts: $parts');
    if (parts.length < 3 || parts[0] != '41') return {};
    final data = <String, double>{};
    try {
      switch (parts[1]) {
        case '05':
          data['coolant_temp'] = int.parse(parts[2], radix: 16).toDouble() - 40;
          break;
        case '0C':
          if (parts.length > 3) {
            data['rpm'] = int.parse(parts[2] + parts[3], radix: 16) / 4;
          }
          break;
        case '0D':
          data['speed'] = int.parse(parts[2], radix: 16).toDouble();
          break;
      // case '2F':
      //   data['fuel_level'] = int.parse(parts[2], radix: 16) * 100 / 255;
      //   break;
        case '11':
          data['throttle_pos'] = int.parse(parts[2], radix: 16) *100/255;
          break;

      }
    } catch (e) {
      debugPrint('[PARSE ERROR] $e');
    }
    return data;
  }
  List<String> _parseDTCResponse(String raw) {
    final dtcs = <String>[];
    raw = raw.replaceAll(' ', ''); // Clean spaces
    if (!raw.startsWith('43') && !raw.startsWith('47')) {
      debugPrint('[DTC PARSE] Invalid DTC response: $raw');
      return dtcs;
    }
    final dtcData = raw.substring(2);
    debugPrint('[DTC PARSE] Processing DTC data: $dtcData');
    for (var i = 0; i + 4 <= dtcData.length; i += 4) {
      final code = dtcData.substring(i, i + 4);
      if (code == '0000') continue; // Skip padding
      final dtc = _decodeDTC(code);
      debugPrint('[DTC PARSE] Raw: $code → Decoded: $dtc');
      dtcs.add(dtc);
    }
    debugPrint('[DTC PARSE] Found ${dtcs.length} DTCs: $dtcs');
    return dtcs;
  }
  String _decodeDTC(String code) {
    final firstByte = int.parse(code.substring(0, 2), radix: 16);
    final secondByte = int.parse(code.substring(2, 4), radix: 16);
    final type = ['P', 'C', 'B', 'U'][(firstByte & 0xC0) >> 6];
    final firstDigit = ((firstByte & 0x30) >> 4).toString();
    final secondDigit = (firstByte & 0x0F).toRadixString(16).toUpperCase();
    final thirdAndFourth = secondByte
        .toRadixString(16)
        .padLeft(2, '0')
        .toUpperCase();
    return '$type$firstDigit$secondDigit$thirdAndFourth';
  }
  void _handleError(String prefix, dynamic error, StackTrace st) {
    _isConnected = false;
    _isReconnecting = false;
    _updateStatus('$prefix: ${error.toString()}');
    debugPrint('$prefix: $error\n$st');
    if (!_isDisposing) _reconnect();
  }
  Future<void> _handleDisconnection() async {
    if (!_isDisposing) {
      _isConnected = false;
      _updateStatus('Disconnected');
      _reconnect();
    }
  }
  void _reconnect() {
    if (!_isReconnecting && !_isDisposing) {
      Future.delayed(reconnectDelay, initConnection);
    }
  }
  void _updateStatus(String message) {
    if (!_statusController.isClosed) {
      _statusController.add(message);
    }
  }
  Future<void> _stopOtherModes() async {
    _isMode1Active = false;
    _mode1Timer?.cancel();
  }

  Future<List<String>> readPendingDTCs() async {
    const command = '07';
    _logCommandLifecycle(command, 'START');
    try {
      _logCommandLifecycle(command, 'SENDING');
      final response = await _sendCommand(command);
      _logCommandLifecycle(command, 'RESPONSE', extra: response);
      if (response.startsWith('47')) {
        final pendingDtcs = _parseDTCResponse(
            response.replaceFirst('47', '43'));
        _logCommandLifecycle(
            command, 'PARSED', extra: '${pendingDtcs.length} DTCs');
        _currentData = _currentData.copyWith(pendingDtcs: pendingDtcs);
        _dataController.add(_currentData);
        return pendingDtcs;
      } else {
        _logCommandLifecycle(command, 'INVALID_RESPONSE');
        _currentData = _currentData.copyWith(pendingDtcs: []);
        _dataController.add(_currentData);
      }
    } catch (e) {
      _logCommandLifecycle(command, 'ERROR', extra: e.toString());
    } finally {
      _logCommandLifecycle(command, 'COMPLETE');
    }
    return [];

  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  final _commandQueue = Queue<Function>();
  bool _isProcessingQueue = false;
  Timer? _mode7MonitorTimer;

  Future<void> _processCommandQueue() async {
    debugPrint('[QUEUE] CHECKING (Length: ${_commandQueue
        .length}, Processing: $_isProcessingQueue)');
    if (_isProcessingQueue) {
      debugPrint('[QUEUE] SKIP - Already processing');
      return;
    }
    if (_commandQueue.isEmpty) {
      debugPrint('[QUEUE] SKIP - Empty');
      return;
    }
    _isProcessingQueue = true;
    try {
      final command = _commandQueue.removeFirst();
      debugPrint('[QUEUE] PROCESSING: ${command.runtimeType}');
      await command();
    } catch (e) {
      debugPrint('[QUEUE] ERROR: $e');
    } finally {
      _isProcessingQueue = false;
      debugPrint('[QUEUE] COMPLETED (Remaining: ${_commandQueue.length})');
      if (_commandQueue.isNotEmpty) {
        debugPrint('[QUEUE] CONTINUING with next item');
        _processCommandQueue();
      }
    }
  }
  // Future<void> startMode7Monitoring() async {
  //   debugPrint(
  //       '[Mode7] INITIALIZING with queue length: ${_commandQueue.length}');
  //   _mode7MonitorTimer = Timer.periodic(Duration(seconds: 120), (timer) {
  //     debugPrint('[Mode7] TIMER TICK - Queue length: ${_commandQueue.length}');
  //     debugPrint('[Mode7] ADDING to queue: ${readPendingDTCs.runtimeType}');
  //     _commandQueue.add(() {
  //       debugPrint('[Mode7] QUEUE EXECUTION STARTED');
  //       return readPendingDTCs();
  //     });
  //     debugPrint('[Mode7] FORCING QUEUE PROCESSING');
  //     _processCommandQueue();
  //   });
  // }
  Future<Map<String, dynamic>> getFreezeFrameForDTC(String dtc) async {
    try {
      final dtcCode = dtc.substring(1); // Remove first letter
      debugPrint('[FreezeFrame] Selecting DTC: 02$dtcCode');

      // Send the freeze frame request (combines DTC selection and data request)
      final response = await _sendCommand('02$dtcCode');
      debugPrint('[FreezeFrame] Raw Response: $response');

      if (response == 'NO DATA') {
        return {'Error': 'No freeze frame data available'};
      }

      return _parseFreezeFrameData(response);
    } catch (e) {
      debugPrint('[FreezeFrame] Error: $e');
      return {'Error': e.toString()};
    }
  }

  Map<String, dynamic> _parseFreezeFrameData(String response) {
    final data = <String, dynamic>{};
    // Clean and validate response
    final cleanResponse = response.replaceAll(RegExp(r'[\r\n>]'), '').trim();
    final parts = cleanResponse.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty || parts[0] != '42' || parts.length < 3) {
      return {'Error': 'Invalid response format'};
    }
    // Parse DTC (bytes 2-3)
    data['DTC'] = 'P${parts[1]}${parts[2]}';
    // Parse parameters (starting from byte 4)
    for (int i = 3; i < parts.length; i += 2) {
      if (i + 1 >= parts.length) break;
      final pid = parts[i];
      final value = parts[i + 1];
      switch (pid) {
        case '01': // Monitor status
          data['MonitorStatus'] = '0x$value';
          break;
        case '05': // Coolant temp
          data['CoolantTemp'] = int.parse(value, radix: 16) - 40;
          break;
        case '0C': // RPM (may be 2 bytes)
          if (i + 2 < parts.length && parts[i + 2].length == 2) {
            // Handle 2-byte RPM value (e.g., "1F B0")
            final rpmValue = (int.parse(value, radix: 16) << 8) |
            int.parse(parts[i + 1], radix: 16);
            data['RPM'] = rpmValue / 4.0;
            i++; // Skip next byte since we consumed it
          }
          break;
        case '0D': // Vehicle speed
          data['Speed'] = int.parse(value, radix: 16).toDouble();
          break;
      // Add more PID cases as needed
        default:
          data['PID_$pid'] = value;
      }
    }
    return data;
  }

  Future<String> getVehicleVIN() async {
    try {
      debugPrint('[VIN] Requesting VIN...');
      final response = await _sendCommand('0902\r');

      if (response == 'TIMEOUT' || response == 'ERROR') {
        return '';
      }


      final vin = _parseVINResponse(response);
      if (vin.isNotEmpty) {
        _currentData = _currentData.copyWith(vin: vin);
        _dataController.add(_currentData);

        // 🔽 Call the API and print the car details here
        final carDetails = await extractSelectedCarDetails(vin);
        if (carDetails.isNotEmpty) {
          print('--- Car Details for VIN: $vin ---');
          carDetails.forEach((key, value) {
            print('$key: $value');
          });
        } else {
          print('No car details found for VIN: $vin');
        }

      }
      return vin;


    } catch (e) {
      debugPrint('[VIN] Error: $e');
      return '';
    }
  }
  String _parseVINResponse(String response) {
    try {
      // Clean the response by removing spaces and '>' characters
      final cleanResponse = response.replaceAll(RegExp(r'[\s>]'),'');
      debugPrint('[VIN] Cleaned response: $cleanResponse');

      // Split into individual frames (each starting with 4902)
      final frames = <String>[];
      int currentPos = 0;

      while (currentPos < cleanResponse.length) {
        // Find the next frame start (4902)
        final nextFrame = cleanResponse.indexOf('4902', currentPos);
        if (nextFrame == -1) break;

        // Find where this frame ends (either at next 4902 or end of string)
        final nextFrameEnd = cleanResponse.indexOf('4902', nextFrame + 4);
        final frameEnd = nextFrameEnd == -1 ? cleanResponse.length : nextFrameEnd;

        final frame = cleanResponse.substring(nextFrame, frameEnd);
        frames.add(frame);
        debugPrint('[VIN] Found frame: $frame');

        currentPos = frameEnd;
      }

      if (frames.isEmpty) {
        debugPrint('[VIN] No valid frames found');
        return '';
      }

      // Process each frame and extract VIN bytes
      final vinBytes = <String>[];
      for (final frame in frames) {
        if (frame.length < 6) continue; // 4902 + at least frame number (2) + some data

        final frameNumber = frame.substring(4, 6);
        final frameData = frame.substring(6);
        debugPrint('[VIN] Processing frame $frameNumber with data: $frameData');

        // Extract each byte (2 characters)
        for (var i = 0; i < frameData.length; i += 2) {
          if (i + 2 <= frameData.length) {
            vinBytes.add(frameData.substring(i, i + 2));
          }
        }
      }

      if (vinBytes.isEmpty) {
        debugPrint('[VIN] No VIN bytes extracted');
        return '';
      }

      // Convert hex to ASCII
      final vin = vinBytes.map((hex) {
        try {
          return String.fromCharCode(int.parse(hex, radix: 16));
        } catch (e) {
          debugPrint('[VIN] Error parsing hex $hex: $e');
          return '';
        }
      }).join();

      debugPrint('[VIN] Parsed VIN: $vin');
      return vin;
    } catch (e) {
      debugPrint('[VIN] Parse error: $e');
      return '';
    }
  }

  Future<Map<String, String?>> extractSelectedCarDetails(String vin) async {
    final url = 'https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/$vin?format=json';

    final List<String> wantedVariables = [
      "Make",
      "Model",
      "Model Year",
    ];

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['Results'];
        final Map<String, String?> selectedDetails = {};

        for (final item in results) {
          if (wantedVariables.contains(item['Variable'])) {
            selectedDetails[item['Variable']] = item['Value'];
          }
        }
        // 🖨️ Print results in terminal
        print('--- Car Details for VIN: $vin ---');
        selectedDetails.forEach((key, value) {
          print('$key: $value');
        });

        return selectedDetails;
      } else {
        throw Exception('Failed to fetch car details from API: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching filtered car details: $e');
      return {};
    }
  }


}
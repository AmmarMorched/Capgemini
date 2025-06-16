import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ObdDiscovery {
  static const int udpPort = 35001;
  static const int tcpPort = 35000;
  static const Duration timeout = Duration(seconds: 3);


  static Future<String?> discoverIp() async {
    // 1. Try simulator discovery via UDP broadcast
    final ipFromUdp = await _tryUdpDiscovery();
    if (ipFromUdp != null) {
      print("[DISCOVERY] Found simulator at $ipFromUdp");
      return ipFromUdp;
    }

    // 2. Try known OBD-II dongle IPs (real hardware)
    final fallbackIps = ['192.168.0.10', '192.168.1.10'];
    for (final ip in fallbackIps) {
      final ok = await testTcpConnection(ip, tcpPort);
      if (ok) {
        print("[DISCOVERY] Found real OBD dongle at $ip");
        return ip;
      }
    }

    // 3. Optional: try full subnet scan (slow)
    // Could be added later

    print("[DISCOVERY] No OBD device found");
    return null;
  }

  static Future<String?> _tryUdpDiscovery() async {
    try {
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;

      final message = utf8.encode('WHO_IS_OBD');
      socket.send(message, InternetAddress('255.255.255.255'), udpPort);

      final completer = Completer<String?>();
      final timer = Timer(timeout, () {
        socket.close();
        if (!completer.isCompleted) completer.complete(null);
      });

      socket.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = socket.receive();
          if (datagram != null) {
            final response = utf8.decode(datagram.data).trim();
            if (response.startsWith("OBD_HERE:")) {
              final ip = response.split(":").last.trim();
              timer.cancel();
              socket.close();
              completer.complete(ip);
            }
          }
        }
      });

      return completer.future;
    } catch (e) {
      print("UDP discovery failed: $e");
      return null;
    }
  }

  static Future<bool> testTcpConnection(String ip, int port) async {
    try {
      final socket = await Socket.connect(ip, port, timeout: timeout);
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}

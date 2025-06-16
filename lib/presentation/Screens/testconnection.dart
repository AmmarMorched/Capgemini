// import 'package:flutter/material.dart';
// import 'package:network_info_plus/network_info_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
//
//
// class connection extends StatefulWidget {
//   const connection({super.key});
//
//   @override
//   State<connection> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<connection> {
//   String? wifiName = 'Checking...';
//   String? lastKnownIp;
//
//   @override
//   void initState() {
//     super.initState();
//     loadWifiInfo();
//   }
//
//   Future<void> loadWifiInfo() async {
//     try {
//       final info = await NetworkInfo().getWifiName();
//       final prefs = await SharedPreferences.getInstance();
//       final ip = prefs.getString('last_obd_ip');
//       setState(() {
//         wifiName = info ?? 'Unknown';
//         lastKnownIp = ip;
//       });
//     } catch (_) {
//       setState(() {
//         wifiName = 'Unavailable';
//       });
//     }
//   }
//
//   void connectToObd() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ObdTestScreen(initialIp: lastKnownIp),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("OBD-II Wi-Fi Tester")),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.wifi, size: 60),
//               const SizedBox(height: 20),
//               Text("Connected Wi-Fi: $wifiName", style: const TextStyle(fontSize: 16)),
//               const SizedBox(height: 20),
//               const Text(
//                 "1. Plug your OBD-II dongle into your car\n"
//                     "2. Connect your phone to the OBD Wi-Fi\n"
//                     "3. Tap below to begin",
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 30),
//               ElevatedButton.icon(
//                 onPressed: connectToObd,
//                 icon: const Icon(Icons.directions_car),
//                 label: const Text("Connect to OBD-II"),
//               ),
//               if (lastKnownIp != null) ...[
//                 const SizedBox(height: 10),
//                 Text("Last connected IP: $lastKnownIp"),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

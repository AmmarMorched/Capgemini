// import 'package:flutter/material.dart';
// import 'package:nitro_nest/domain/services/ModeManager.dart';
// import 'package:provider/provider.dart';
//
// import '../screens/home_screen.dart';
// import '../screens/testconnection.dart';
// import '../screens/chatbot_screen.dart';
// import '../screens/history.dart';
// import '../screens/settings.dart';
//
//
// class BottomNavBar extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     final isDark = theme.brightness == Brightness.dark;
//     return Container(
//       margin: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
//       height: 80,
//       decoration: BoxDecoration(
//         color: theme.bottomNavigationBarTheme.backgroundColor,
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: [
//           BoxShadow(
//             color: isDark ? Colors.black54 : Colors.grey.withOpacity(0.5),
//             blurRadius: 10,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Positioned.fill(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 IconButton(
//                 icon: Icon(Icons.home,
//                     color: theme.bottomNavigationBarTheme.unselectedItemColor,
//                     size: 28
//                 ),
//                 onPressed:() {
//                   final modeManager = context.read<ModeManager>();
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder:(context)=> HomeScreen())
//                   );
//                 }
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.chat,
//                       color:
//                       theme.bottomNavigationBarTheme.unselectedItemColor),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const ChatbotScreen()),
//                     );
//                   },
//                 ),
//                 const SizedBox(width: 50),
//                 IconButton(
//                   icon: Icon(Icons.settings,
//                       color:
//                       theme.bottomNavigationBarTheme.unselectedItemColor),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) =>  SettingsScreen()),
//                     );
//                   },
//                 ),
//                 IconButton(
//                     // Space for floating button
//                 icon : Icon(Icons.history,
//                     color: theme.bottomNavigationBarTheme.unselectedItemColor,
//                     size: 28
//                 ),
//                     onPressed:(){
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                           builder: (context) => const HistoryScreen()),
//                           );
//                     },
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// /// A floating power button that uses the theme's primary color.
// class FloatingPowerButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return GestureDetector(
//       onTap: () {
//         // Show the dialog with OBD commands
//         _showCommandDialog(context);
//       },
//       child: Container(
//         margin: const EdgeInsets.only(top: 30),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: theme.floatingActionButtonTheme.backgroundColor,
//           boxShadow: [
//             BoxShadow(
//               color: theme.primaryColor.withOpacity(0.5),
//               blurRadius: 10,
//               spreadRadius: 1,
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.all(16),
//         child: const Icon(Icons.power_settings_new, color: Colors.white, size: 32),
//       ),
//     );
//   }
//   // Function to show the SimpleDialog with OBD commands
//   void _showCommandDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) {
//         return SimpleDialog(
//           title: Text("Send command to OBD"),
//           children: [
//             ...['Reset','Misfire Detection', 'Fuel System Performance', 'Transmission Control System Test',
//               'Mass Air Flow', 'RPM Overuse', 'Coolant Temperature Sensor',
//               'Fuel Injector Pulse Test', 'Cooling Fan Test']
//                 .map((command) => ListTile(
//               title: Text(command),
//               onTap: () {
//                 _sendCommand(command);
//                 Navigator.pop(context);
//               },
//             )).toList(),
//           ],
//         );
//       },
//     );
//   }
//
//   // Simulating sending the selected command to OBD
//   void _sendCommand(String command) {
//     print("Command sent to OBD: $command");
//     // You can replace the print statement with actual code to communicate with the OBD device.
//   }
// }

import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final Function(int) onItemSelected;
  final int currentIndex;

  const BottomNavBar({
    Key? key,
    required this.onItemSelected,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.download,
            label: 'Diagnostics ',
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.engineering,
            label: 'Trips',
            index: 1,
          ),
          _buildNavItem(
            icon: Icons.security,
            label: 'Home',
            index: 2,
          ),
          _buildNavItem(
            icon: Icons.calendar_today,
            label: 'Key planner',
            index: 3,
          ),
          _buildNavItem(
            icon: Icons.account_circle,
            label: 'Account',
            index: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:capgemini/views/profile_screen.dart';
import 'package:capgemini/views/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../view_models/OBD_viewmodel.dart';
import '../widgets/Menu_Drawer/bubble_drawer.dart';
import '../widgets/SlidingPanel.dart';
import '../widgets/top_navbar.dart';
import '../widgets/obd_connection_status.dart';
import '../widgets/OBDCards/SpeedometerGauge.dart';
import 'WifiScanScreen.dart';
import 'login_screen.dart';
import '../view_models/auth_viewmodel.dart';
import '../view_models/profile_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreenContent();
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({Key? key}) : super(key: key);

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  bool _isPanelVisible = false;

  late final OBDViewModel _obdViewModel;

  @override
  void initState() {
    super.initState();
    _obdViewModel = Provider.of<OBDViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _obdViewModel.connectToDevice(); // Attempt connection after first frame
    });
  }

  void _togglePanel() {
    setState(() {
      _isPanelVisible = !_isPanelVisible;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final obdViewModel = Provider.of<OBDViewModel>(context);
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Builder(
          builder: (context) {
            return TopNavBar(
              isDrawerOpen: false,
              onMenuTap: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
      ),
      drawer: BubbleDrawer(
        onProfileTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
        onConnectOBDTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WifiScanScreen()),
          );
        },
        onSettingsTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsScreen()),
          );
        },
        onLogoutTap: () async {
          await authViewModel.logout();
          await profileViewModel.logout();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
          );
        },
        onClose: () {
          Navigator.pop(context);
        },
      ),

      backgroundColor: AppTheme.backgroundColor,

      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppTheme.backgroundColor,
              child: Center(
                child: obdViewModel.isLoading
                    ? const CircularProgressIndicator()
                    : obdViewModel.isConnected
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Status: ${obdViewModel.statusMessage}"),
                    const SizedBox(height: 16),

                    Text("Speed: ${obdViewModel.currentData.speed?.toStringAsFixed(0) ?? 0} km/h"),
                    Text("RPM: ${obdViewModel.currentData.rpm?.toStringAsFixed(0) ?? 0}"),
                    Text("Coolant Temp: ${obdViewModel.currentData.coolantTemp?.toStringAsFixed(0) ?? 0} °C"),
                    Text("Throttle Position: ${obdViewModel.currentData.throttlePos?.toStringAsFixed(0) ?? 0}%"),

                    const SizedBox(height: 20),

                    if (obdViewModel.dtcs.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Trouble Codes:", style: TextStyle(fontWeight: FontWeight.bold)),
                          ...obdViewModel.dtcs.map((dtc) => Text("⚠️ $dtc")),
                        ],
                      )
                    else
                      const Text("No trouble codes."),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: () => obdViewModel.readDTCs(),
                      icon: const Icon(Icons.warning),
                      label: const Text("Read DTCs"),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () => obdViewModel.clearDTCs(),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text("Clear DTCs"),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () => obdViewModel.startReading(),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("Start Reading"),
                    ),
                    //const SizedBox(height: 10),
                    // ElevatedButton.icon(
                    //   onPressed: () => obdViewModel.stopReading(),
                    //   icon: const Icon(Icons.stop),
                    //   label: const Text("Stop Reading"),
                    // ),
                  ],
                )
                    : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpeedometerGauge(
                        currentSpeed: obdViewModel.currentData.speed ?? 0,
                        maxSpeed: 200,
                        needleColor: Colors.red,
                        gaugeColor: Colors.blue,
                        textColor: Colors.black,
                        size: 300,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Speedometer',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${obdViewModel.currentData.speed?.toStringAsFixed(1) ?? '0'} km/h',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'RPM: ${obdViewModel.currentData.rpm?.toStringAsFixed(0) ?? '0'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SlidingPanel(),
        ],
      ),
    );
  }
}
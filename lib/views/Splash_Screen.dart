import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/ObdDiscover_viewmodel.dart';
import '../view_models/auth_viewmodel.dart';
import '../view_models/OBD_viewmodel.dart';
import '../views/home_screen.dart';
import '../views/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginAndDiscoverDevice();
  }

  Future<void> _checkLoginAndDiscoverDevice() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final obdDiscoveryViewModel = Provider.of<ObdDiscoveryViewModel>(context, listen: false);
    final obdViewModel = Provider.of<OBDViewModel>(context, listen: false);

    bool loggedIn = await authViewModel.isLoggedIn();

    if (loggedIn) {
      // Try discovering OBD device
      await obdDiscoveryViewModel.startDiscovery();

      if (obdDiscoveryViewModel.obdIpAddress != null) {
        // Found device -> connect
        await obdViewModel.connectToDevice();
      }

      // Navigate to HomeScreen regardless of discovery result
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else {
      // Not logged in -> go to Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Initializing..."),
          ],
        ),
      ),
    );
  }
}
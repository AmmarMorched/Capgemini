import 'package:capgemini/presentation/features/Home/pages/home_screen.dart';
import 'package:capgemini/presentation/features/auth/pages/login_screen.dart';
import 'package:capgemini/presentation/features/auth/pages/signup_screen.dart';
import 'package:capgemini/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'domaine/Services/ModeManager.dart';
import 'domaine/Services/OBDdiscovery.dart';
import 'domaine/Services/UserService.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize OBD discovery
  String? discoveredIp;

  try {
    discoveredIp = await ObdDiscovery.discoverIp();
  } on Exception catch (e) {
    debugPrint('OBD discovery failed: $e');
  }

  // Create ModeManager with default values
  final modeManager = ModeManager(
    serverAddress: discoveredIp ?? "127.0.0.1",
    serverPort: ObdDiscovery.tcpPort,
  );

  // If we have a discovered IP, try to connect immediately
  if (discoveredIp != null) {
    try {
      await modeManager.initConnection();
      if (modeManager.isConnected) {
        debugPrint('Successfully connected to OBD device at $discoveredIp');
      } else {
        debugPrint('Failed to connect to OBD device at $discoveredIp');
      }
    } catch (e) {
      debugPrint('Connection error: $e');
    }
  } else {
    debugPrint('No OBD device found, using default connection settings');
  }

  // Initialize the ModeManagerProvider with our ModeManager instance
  // Check login status
  final bool loggedIn = await UserService.isLoggedIn();

  runApp(MyApp(loggedIn: loggedIn,),);
}

class MyApp extends StatelessWidget {
  final bool loggedIn;

  const MyApp({
    super.key,
    required this.loggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle Diagnostics',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: loggedIn
          ? HomeScreen()
          : SignUpScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => HomeScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          return MaterialPageRoute(
            builder: (context) => HomeScreen(),
          );
        }
        return null;
      },
    );
  }
}
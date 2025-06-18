import 'package:capgemini/view_models/OBD_viewmodel.dart';
import 'package:capgemini/view_models/ObdDiscover_viewmodel.dart';
import 'package:capgemini/view_models/google_auth_viewmodel.dart';
import 'package:capgemini/view_models/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:capgemini/services/UserService.dart';
import 'package:capgemini/view_models/auth_viewmodel.dart';
import 'package:capgemini/views/login_screen.dart';
import 'package:capgemini/views/signup_screen.dart';
import 'package:capgemini/views/home_screen.dart';
import 'package:capgemini/utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Check if user is logged in
  final bool loggedIn = await UserService.isLoggedIn();

  runApp(
    MultiProvider(
      providers: [
        // Auth ViewModel
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(),
        ),
        // Google Auth ViewModel
        ChangeNotifierProvider(
          create: (_) => GoogleAuthViewModel(),
        ),

        // Profile ViewModel
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(),
        ),

        // OBD Discovery ViewModel
        ChangeNotifierProvider(
          create: (_) => ObdDiscoveryViewModel(),
        ),

        // OBD Data ViewModel (will use discovery service)
        ChangeNotifierProvider(
          create: (_) => OBDViewModel(),
        ),
      ],
      child: MyApp(loggedIn: loggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool loggedIn;

  const MyApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle Diagnostics',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: loggedIn ? const HomeScreen() : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}
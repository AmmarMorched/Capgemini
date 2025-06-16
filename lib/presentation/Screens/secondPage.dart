import 'package:flutter/material.dart';

import '../features/auth/pages/login_screen.dart';

class Secondpage extends StatelessWidget {
  const Secondpage({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;
    final textTheme = theme.textTheme;
    final buttonTheme = theme.elevatedButtonTheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // App Logo
              Row(
                children: [
                  Icon(
                    Icons.car_crash,
                    color: Theme.of(context).iconTheme.color, // Use theme icon color
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Auto ',
                          style: TextStyle(
                            color: theme.scaffoldBackgroundColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                         TextSpan(
                          text: 'IQ!',
                          style: TextStyle(
                            color: theme.scaffoldBackgroundColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Car Image
              Center(
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.scaffoldBackgroundColor,
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'lib/assets/car.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 220,
                        width: 300,
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "Car Image",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Spacer(),
              // Welcome Text
              Text(
                'Plug In. Power Up,',
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const Text(
                'Auto IQ!',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Professional inspection of the machine allows you to determine exactly which systems have problems at the earliest stages',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              // Action Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 36),

                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the main screen (login screen)
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Let's go!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
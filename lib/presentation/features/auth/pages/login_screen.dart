import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../application/user/usecases/user_login.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../domaine/entities/User.dart';
import '../../../../domaine/repositories/userRepo.dart';
import '../../../Screens/testconnection.dart';
import 'signup_screen.dart';
import '../../Home/pages/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isVisible = false;
  bool isLoading = false;
  late final LoginUser loginUserUseCase;

  @override
  void initState() {
    super.initState();
    loginUserUseCase = LoginUser(UserRepositoryImpl());
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ListTile(
                        title: Text(
                          "Welcome Back",
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Email
                      buildTextField(
                        controller: emailController,
                        hintText: "Email",
                        icon: Icons.email,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email is required";
                          } else if (!RegExp(
                              r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
                              .hasMatch(value)) {
                            return "Please enter a valid email address";
                          }
                          return null;
                        },
                        isPassword: false,
                      ),
                      // Password
                      buildTextField(
                        controller: passwordController,
                        hintText: "Password",
                        icon: Icons.lock,
                        validator: (value) => value!.isEmpty
                            ? "Password is required"
                            : value.length < 6
                            ? "Password must be at least 6 characters"
                            : null,
                        isPassword: true,
                        suffixIcon: IconButton(
                          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Login Button
                      isLoading
                          ? const CircularProgressIndicator()
                          : Container(
                              height: 55,
                              width: MediaQuery.of(context).size.width * .9,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: theme.primaryColor,
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    bool isOnline = await _checkInternetConnection();
                                    if (!isOnline) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("No internet connection."),
                                          backgroundColor: Theme.of(context).colorScheme.error,
                                        ),
                                      );
                                      return;
                                    }

                                    try {
                                      bool isLoggedIn = await loginUserUseCase(
                                        emailController.text,
                                        passwordController.text,
                                      );

                                      if (isLoggedIn) {
                                        await Future.delayed(const Duration(seconds: 1));
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const HomeScreen(),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Login failed. Please check your credentials."),
                                            backgroundColor: Theme.of(context).colorScheme.error,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Login failed: $e"),
                                          backgroundColor: Theme.of(context).colorScheme.error,
                                        ),
                                      );
                                    }

                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                                child: Text(
                                  "LOGIN",
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 20),
                      // Don't have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: theme.textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Sign up",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: theme.scaffoldBackgroundColor.withOpacity(0.6),
                child: Center(
                  child: CircularProgressIndicator(
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isPassword,
    required String? Function(String?) validator,
    IconButton? suffixIcon,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.primaryColor.withOpacity(.2),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: isPassword && !isVisible,
        decoration: InputDecoration(
          icon: Icon(icon, color: theme.iconTheme.color),
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
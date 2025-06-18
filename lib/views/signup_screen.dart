import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/Users.dart';
import '../view_models/auth_viewmodel.dart';
import '../view_models/google_auth_viewmodel.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool isVisible = false;

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
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final googleAuthViewModel = Provider.of<GoogleAuthViewModel>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ListTile(
                        title: Text(
                          "Join AutoIQ Family",
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Username Field
                      buildTextField(
                        controller: usernameController,
                        hintText: "Username",
                        icon: Icons.person,
                        validator: (value) =>
                        value!.isEmpty ? "Username is required" : null,
                        isPassword: false,
                      ),

                      // Email Field
                      buildTextField(
                        controller: emailController,
                        hintText: "Email",
                        icon: Icons.email,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email is required";
                          } else if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
                              .hasMatch(value)) {
                            return "Please enter a valid email address";
                          }
                          return null;
                        },
                        isPassword: false,
                      ),

                      // Phone Field
                      buildTextField(
                        controller: phoneController,
                        hintText: "Phone number",
                        icon: Icons.phone,
                        validator: (value) =>
                        value!.isEmpty ? "Phone number is required" : null,
                        isPassword: false,
                      ),

                      // Password Field
                      buildTextField(
                        controller: passwordController,
                        hintText: "Password",
                        icon: Icons.lock,
                        isPassword: true,
                        validator: (value) => value!.isEmpty
                            ? "Password is required"
                            : value.length < 6
                            ? "Password must be at least 6 characters"
                            : null,
                        suffixIcon: IconButton(
                          icon: Icon(isVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                        ),
                      ),

                      // Confirm Password Field
                      buildTextField(
                        controller: confirmPasswordController,
                        hintText: "Confirm Password",
                        icon: Icons.lock,
                        isPassword: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Password confirmation is required";
                          } else if (passwordController.text !=
                              confirmPasswordController.text) {
                            return "Passwords don't match";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Show Error from ViewModel
                      if (authViewModel.error != null)
                        Text(
                          authViewModel.error!,
                          style: TextStyle(color: Colors.red),
                        ),

                      const SizedBox(height: 10),

                      // Sign Up Button
                      authViewModel.isLoading
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
                              bool isOnline =
                              await _checkInternetConnection();
                              if (!isOnline) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content:
                                  Text("No internet connection."),
                                  backgroundColor: Colors.red,
                                ));
                                return;
                              }

                              final user = Users(
                                usrName: usernameController.text,
                                usrEmail: emailController.text,
                                phone: int.tryParse(
                                    phoneController.text) ??
                                    0,
                                usrPassword: passwordController.text,
                              );

                              final success =
                              await authViewModel.signup(user);

                              if (success) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    const HomeScreen(),
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(
                            "SIGN UP",
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Already have account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: theme.textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Login",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.hintColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Google Sign-Up Button
                      Consumer<GoogleAuthViewModel>(
                        builder: (context, googleAuthViewModel, _) {
                          return googleAuthViewModel.isLoading
                              ? const CircularProgressIndicator()
                              : Container(
                            height: 55,
                            width:
                            MediaQuery.of(context).size.width * .9,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: TextButton.icon(
                              onPressed: () async {
                                bool isOnline =
                                await _checkInternetConnection();
                                if (!isOnline) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                        "No internet connection."),
                                    backgroundColor: Colors.red,
                                  ));
                                  return;
                                }

                                bool success = await googleAuthViewModel
                                    .signInWithGoogle();

                                if (success) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      const HomeScreen(),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(googleAuthViewModel
                                        .error ??
                                        "Google sign-up failed"),
                                    backgroundColor: Colors.red,
                                  ));
                                }
                              },
                              icon: Image.asset(
                                'lib/assets/google.png',
                                height: 24,
                              ),
                              label: Text(
                                'Sign up with Google',
                                style: TextStyle(
                                    color: theme.primaryColor),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Full-screen loading overlay
          if (authViewModel.isLoading || googleAuthViewModel.isLoading)
            Positioned.fill(
              child: Container(
                color: theme.scaffoldBackgroundColor.withOpacity(0.6),
                child: const Center(
                  child: CircularProgressIndicator(),
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
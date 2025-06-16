import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../application/user/usecases/user_signup.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../domaine/entities/User.dart';
import '../../../../domaine/repositories/userRepo.dart';
import '../../../../domaine/Services/Google_AuthService.dart';
import '../../Home/pages/home_screen.dart';
import '../../../Screens/testconnection.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final phone = TextEditingController();
  final confirmPassword = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isVisible = false;
  bool isLoading = false;
  late final SignupUser signUpUseCase;
  final GoogleAuthService signUpWithGoogle = GoogleAuthService();

  @override
  void initState() {
    super.initState();
    signUpUseCase = SignupUser(UserRepositoryImpl());
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
    username.dispose();
    email.dispose();
    password.dispose();
    phone.dispose();
    confirmPassword.dispose();
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
                          "Join AutoIQ Family",
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Username
                      buildTextField(
                        controller: username,
                        hintText: "Username",
                        icon: Icons.person,
                        validator: (value) =>
                            value!.isEmpty ? "Username is required" : null,
                        isPassword: false,
                      ),
                      // Email
                      buildTextField(
                        controller: email,
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
                      // Phone Number
                      buildTextField(
                        controller: phone,
                        hintText: "Phone number",
                        icon: Icons.phone,
                        validator: (value) =>
                            value!.isEmpty ? "Phone number is required" : null,
                        isPassword: false,
                      ),
                      // Password
                      buildTextField(
                        controller: password,
                        hintText: "Password",
                        icon: Icons.lock,
                        isPassword: true,
                        validator: (value) => value!.isEmpty
                            ? "Password is required"
                            : value.length < 6
                            ? "Password must be at least 6 characters"
                            : null,
                        suffixIcon: IconButton(
                          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                        ),
                      ),
                      // Confirm Password
                      buildTextField(
                        controller: confirmPassword,
                        hintText: "Confirm Password",
                        icon: Icons.lock,
                        isPassword: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Password confirmation is required";
                          } else if (password.text != confirmPassword.text) {
                            return "Passwords don't match";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Sign Up Button
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
                                      final user = Users(
                                        usrName: username.text,
                                        usrEmail: email.text,
                                        phone: int.tryParse(phone.text) ?? 0,
                                        usrPassword: password.text,
                                      );

                                      bool isSignedUp = await signUpUseCase(user);

                                      if (isSignedUp) {
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
                                            content: Text("Signup failed. Please try again."),
                                            backgroundColor: Theme.of(context).colorScheme.error,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Signup failed: $e"),
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
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Google Sign Up Button
                      Container(
                        height: 55,
                        width: MediaQuery.of(context).size.width * .9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.primaryColor),
                        ),
                        child: TextButton.icon(
                          onPressed: () async {
                            try {
                              bool isOnline = await _checkInternetConnection();
                              if (!isOnline) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("No internet connection."),
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                  ),
                                );
                                return;
                              }

                              final user = await signUpWithGoogle.signInWithGoogle();
                              if (user != null) {
                                await Future.delayed(const Duration(seconds: 1));
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Google sign-in failed: $e"),
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                ),
                              );
                            }
                          },
                          icon: Image.asset(
                            'lib/assets/google.png',
                            height: 24,
                          ),
                          label: Text(
                            'Sign up with Google',
                            style: TextStyle(color: theme.primaryColor),
                          ),
                        ),
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
// import 'package:flutter/material.dart';
//
// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeIn;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//         vsync: this, duration: const Duration(seconds: 2));
//     _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
//
//     _controller.forward();
//
//     Future.delayed(Duration(seconds: 3), () {
//       Navigator.pushReplacementNamed(context, '/home');
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: FadeTransition(
//         opacity: _fadeIn,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset('assets/autoiq_logo.png', width: 150),
//               SizedBox(height: 20),
//               Text(
//                 'Plug In. Power Up. AutoIQ.',
//                 style: TextStyle(color: Colors.white, fontSize: 18),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

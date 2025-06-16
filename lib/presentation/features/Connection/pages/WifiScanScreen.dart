import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import '../../../../domaine/Services/OBDdiscovery.dart';

class WifiScanScreen extends StatefulWidget {
  const WifiScanScreen({super.key});
  @override
  _WifiScanScreenState createState() => _WifiScanScreenState();
}
class _WifiScanScreenState extends State<WifiScanScreen> with TickerProviderStateMixin{
  bool _isScanning = false;
  String? _foundIP;

  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    // Set up the animation controller for pulsating effect
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _startDiscovery()async {
    setState(() {
      _isScanning = true;
      _foundIP = null;
    });
    _animController.forward();
    final ip = await ObdDiscovery.discoverIp();
    _animController.stop();
    setState(() {
      _isScanning = false;
      _foundIP= ip;
    });


  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;
    final textTheme = theme.textTheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: appBarTheme.backgroundColor,
        elevation: appBarTheme.elevation,
        iconTheme: appBarTheme.iconTheme,
        title: Text(
          "Connect OBD",
          style: appBarTheme.titleTextStyle,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_foundIP == null && !_isScanning)
                ElevatedButton.icon(
                  onPressed: _startDiscovery,
                  icon: Icon(Icons.wifi),
                  label: Text("Start Discovery"),
                )

              else if (_isScanning)
                Column(
                  children: [
                    AnimatedBuilder(
                      animation: _scaleAnim,
                      builder: (_, child){
                        return Transform.scale(
                          scale:_scaleAnim.value,
                          child: child,
                        );
                      },
                      child: Icon(
                        Icons.wifi,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    // CircularProgressIndicator(),
                    // SizedBox(height: 16),
                    // Text("Looking for OBD-II dongle..."),
                    const SizedBox(height: 16),
                    Text(
                      "Loking for OBD-|| dongle ..",
                      style: textTheme.bodyMedium,
                    )
                  ],
                )
              else
                Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 80, color: Theme.of(context).scaffoldBackgroundColor),
                    SizedBox(height: 16),
                    Text("✅ Connected to $_foundIP", textAlign: TextAlign.center),
                    ElevatedButton(
                      onPressed: _startDiscovery,
                      child: Text("Try Again"),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

}
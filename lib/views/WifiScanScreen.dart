import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/OBD_viewmodel.dart';
import '../view_models/ObdDiscover_viewmodel.dart';

class WifiScanScreen extends StatelessWidget {
  const WifiScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WifiScanScreenContent();
  }
}

class WifiScanScreenContent extends StatefulWidget {
  const WifiScanScreenContent({Key? key}) : super(key: key);

  @override
  State<WifiScanScreenContent> createState() => _WifiScanScreenContentState();
}

class _WifiScanScreenContentState extends State<WifiScanScreenContent> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final discoveryVM = Provider.of<ObdDiscoveryViewModel>(context);
    final obdVM = Provider.of<OBDViewModel>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Connect OBD-II"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (discoveryVM.isLoading)
                Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1 + _pulseController.value * 0.2,
                          child: child,
                        );
                      },
                      child: Icon(
                        Icons.wifi,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Looking for OBD-II dongle...",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),

              if (!discoveryVM.isLoading && discoveryVM.obdIpAddress == null)
                ElevatedButton.icon(
                  onPressed: () => discoveryVM.startDiscovery(),
                  icon: const Icon(Icons.wifi),
                  label: const Text("Start Discovery"),
                ),

              if (discoveryVM.obdIpAddress != null)
                Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "✅ Connected to ${discoveryVM.obdIpAddress}",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => discoveryVM.startDiscovery(),
                      child: const Text("Try Again"),
                    ),
                  ],
                ),

              if (discoveryVM.error != null && !discoveryVM.isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    discoveryVM.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Animation<double> _createPulseAnimation(BuildContext context) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: context as TickerProviderStateMixin,
    );

    final animation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });

    controller.forward();

    return animation;
  }
}
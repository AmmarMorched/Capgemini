import 'dart:ui';
import 'package:flutter/material.dart';

class SlidingPanel extends StatefulWidget {
  final double collapsedHeight;
  final double maxExpandedRatio;
  final Color? handleColor;
  final double handleHeight;
  final double handleWidth;

  const SlidingPanel({
    super.key,
    this.collapsedHeight = 100,
    this.maxExpandedRatio = 0.4,
    this.handleColor,
    this.handleHeight = 6,
    this.handleWidth = 40,
  });

  @override
  State<SlidingPanel> createState() => _SlidingPanelState();
}

class _SlidingPanelState extends State<SlidingPanel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isExpanded = false;
  double _contentHeight = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _measureContent());
  }

  void _measureContent() {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * widget.maxExpandedRatio;

    setState(() {
      _contentHeight = maxHeight;
    });
  }

  void togglePanel() {
    isExpanded = !isExpanded;
    _controller.animateTo(isExpanded ? 1.0 : 0.0, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * widget.maxExpandedRatio;

    final panelHeight = widget.collapsedHeight +
        (_contentHeight - widget.collapsedHeight) * _controller.value;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! < -5 && !isExpanded) {
          togglePanel();
        } else if (details.primaryDelta! > 5 && isExpanded) {
          togglePanel();
        }
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: panelHeight,
            color: Colors.black.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: widget.handleWidth,
                    height: widget.handleHeight,
                    decoration: BoxDecoration(
                      color: widget.handleColor ?? Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Use Flexible ListView to prevent overflow and allow expansion
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: isExpanded ? BouncingScrollPhysics() : NeverScrollableScrollPhysics(),
                    children: [
                      _buildStatusItem(
                        icon: Icons.local_gas_station,
                        label: 'Fuel',
                        value: '61%',
                        valueIcon: Icons.refresh,
                      ),
                      const SizedBox(height: 12),
                      _buildStatusItem(
                        icon: Icons.settings,
                        label: 'Engine',
                        value: '90°C',
                        valueIcon: Icons.oil_barrel,
                      ),
                      const SizedBox(height: 12),
                      _buildStatusItem(
                        icon: Icons.bluetooth,
                        label: 'Tyres',
                        value: '> 29 PSI',
                        valueIcon: Icons.speed,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: togglePanel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Close driving mode',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
    IconData? valueIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.lightBlueAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          if (valueIcon != null) ...[
            const SizedBox(width: 8),
            Icon(valueIcon, color: Colors.white70, size: 18),
          ],
        ],
      ),
    );
  }
}

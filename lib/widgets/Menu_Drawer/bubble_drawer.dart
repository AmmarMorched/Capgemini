import 'package:flutter/material.dart';

class BubbleDrawer extends StatefulWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onConnectOBDTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  final VoidCallback onClose;

  const BubbleDrawer({
    super.key,
    required this.onProfileTap,
    required this.onConnectOBDTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
    required this.onClose,

  });

  @override
  State<BubbleDrawer> createState() => _BubbleDrawerState();
}

class _BubbleDrawerState extends State<BubbleDrawer> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: GestureDetector(
        onTap: widget.onClose,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned(
              left: 20,
              top: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnimatedItem(
                    icon: Icons.person,
                    label: 'Profile',
                    onTap: widget.onProfileTap,
                    delay: 0,
                  ),
                  const SizedBox(height: 20),
                  _buildAnimatedItem(
                    icon: Icons.wifi_channel,
                    label: 'Connect OBD',
                    onTap: widget.onConnectOBDTap,
                    delay: 100,
                  ),
                  const SizedBox(height: 20),
                  _buildAnimatedItem(
                    icon: Icons.settings,
                    label: 'Settings',
                    onTap: widget.onSettingsTap,
                    delay: 200,
                  ),
                  const SizedBox(height: 20),
                  _buildAnimatedItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    onTap: widget.onLogoutTap,
                    delay: 300,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required int delay,
  }) {
    return AnimatedOpacity(
      opacity: _animate ? 1 : 0,
      duration: Duration(milliseconds: 300 + delay),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        duration: Duration(milliseconds: 300 + delay),
        offset: Offset(_animate ? 0 : -0.5, 0),
        child: _BubbleItem(
          icon: icon,
          label: label,
          onTap: onTap,
        ),
      ),
    );
  }
}

class _BubbleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BubbleItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: label,
          preferBelow: false,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              splashColor: Colors.white.withOpacity(0.3),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
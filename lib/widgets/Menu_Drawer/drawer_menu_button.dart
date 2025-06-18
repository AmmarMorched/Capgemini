import 'package:flutter/material.dart';

class DrawerMenuButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isOpen;

  const DrawerMenuButton({
    super.key,
    required this.onPressed,
    required this.isOpen,
  });

  @override
  State<DrawerMenuButton> createState() => _DrawerMenuButtonState();
}

class _DrawerMenuButtonState extends State<DrawerMenuButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.onPressed,
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 24,
        height: 24,
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: widget.isOpen ? 11 : 0,
              left: 0,
              child: Container(
                width: 24,
                height: 2,
                color: Colors.white,
                transform: widget.isOpen
                    ? Matrix4.rotationZ(45 * 3.1415927 / 180)
                    : Matrix4.identity(),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: 11,
              left: 0,
              child: Container(
                width: widget.isOpen ? 0 : 24,
                height: 2,
                color: Colors.white,
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: widget.isOpen ? 11 : 22,
              left: 0,
              child: Container(
                width: 24,
                height: 2,
                color: Colors.white,
                transform: widget.isOpen
                    ? Matrix4.rotationZ(-45 * 3.1415927 / 180)
                    : Matrix4.identity(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
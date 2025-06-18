import 'package:flutter/material.dart';

import 'Menu_Drawer/drawer_menu_button.dart';
import 'obd_connection_status.dart';



class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;
  final bool isDrawerOpen;
  const TopNavBar({
    Key? key,
    required this.onMenuTap,
    required this.isDrawerOpen
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      leading: DrawerMenuButton(
        onPressed: onMenuTap,
        isOpen: isDrawerOpen,
      ),
      actions: [const ConnectionStatusIndicator()],
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

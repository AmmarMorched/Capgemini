import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = 'English';

  //final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Load settings on screen open
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language') ?? 'English';

    setState(() {
      _language = savedLanguage;
    });
  }

  void _changeLanguage(String? newValue) async {
    if (newValue == null) return;

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = newValue;
    });

    await prefs.setString('language', newValue);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Language set to $_language")),
    );
  }

  bool _isDrawerOpen = false;

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
          "Settings",
          style: appBarTheme.titleTextStyle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('Language'),
              trailing: DropdownButton<String>(
                value: _language,
                items: ['English', 'Français', 'Español']
                    .map((lang) => DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang),
                ))
                    .toList(),
                onChanged: _changeLanguage,
              ),
            ),

            Divider(),

            // Optional: Add more settings here
            ListTile(
              title: Text("About"),
              subtitle: Text("Learn more about NitroNest"),
              onTap: () {
                // Navigate to AboutScreen or show dialog
              },
            ),

            Spacer(), // Pushes footer down

            Align(
              alignment: Alignment.bottomCenter,
              child: Text("App Version: 1.0.0", style: Theme.of(context).textTheme.titleMedium),
            )
          ],
        ),
      ),
    );
  }
}
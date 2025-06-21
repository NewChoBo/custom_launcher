import 'package:flutter/material.dart';
import 'package:custom_launcher/models/app_settings.dart';

/// Home page widget for Custom Launcher
/// Displays main UI with system tray information
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.title,
    required this.onHideToTray,
    required this.settings,
  });

  final String title;
  final Future<void> Function() onHideToTray;
  final AppSettings settings;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary
            .withValues(alpha: widget.settings.appBarOpacity),
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.minimize),
            onPressed: () async {
              await widget.onHideToTray();
            },
            tooltip: 'Hide to System Tray',
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.rocket_launch, size: 100, color: Colors.deepPurple),
            SizedBox(height: 20),
            Text(
              'Custom Launcher',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Running in System Tray',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'System Tray Features:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('• Left click tray icon to show/hide window'),
                    Text('• Right click tray icon for context menu'),
                    Text('• Click minimize button to hide to tray'),
                    Text('• App continues running in background'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

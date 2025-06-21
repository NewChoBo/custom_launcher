import 'package:flutter/material.dart';
import 'package:custom_launcher/widgets/dashboard_section.dart';

/// Main dashboard layout widget for Custom Launcher
/// Contains the asymmetric grid layout with different sections
class DashboardLayout extends StatelessWidget {
  const DashboardLayout({super.key});

  /// Build quick action button widget
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80, // Fixed width for consistent sizing
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 24, color: Colors.blue.shade600),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Build system information row
  Widget _buildSystemInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Text(value, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  /// Build file item for recent files list
  Widget _buildFileItem(String fileName, IconData icon) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: Colors.indigo.shade600),
      title: Text(
        fileName,
        style: const TextStyle(fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => debugPrint('Open file: $fileName'),
    );
  }

  /// Build favorite app item
  Widget _buildFavoriteApp(String appName, IconData icon) {
    return InkWell(
      onTap: () => debugPrint('Launch app: $appName'),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 20, color: Colors.teal.shade600),
            const SizedBox(height: 4),
            Text(
              appName,
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          // Top header section (full width)
          Expanded(
            flex: 2,
            child: DashboardSection(
              title: 'Quick Actions',
              color: Colors.blue.shade50,
              onTap: () => debugPrint('Quick Actions tapped'),
              child: SizedBox(
                width: double.infinity, // Force full width
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  runAlignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: <Widget>[
                    _buildQuickActionButton(
                      icon: Icons.settings,
                      label: 'Settings',
                      onTap: () => debugPrint('Settings'),
                    ),
                    _buildQuickActionButton(
                      icon: Icons.folder,
                      label: 'Files',
                      onTap: () => debugPrint('Files'),
                    ),
                    _buildQuickActionButton(
                      icon: Icons.web,
                      label: 'Browser',
                      onTap: () => debugPrint('Browser'),
                    ),
                    _buildQuickActionButton(
                      icon: Icons.terminal,
                      label: 'Terminal',
                      onTap: () => debugPrint('Terminal'),
                    ),
                    _buildQuickActionButton(
                      icon: Icons.code,
                      label: 'VS Code',
                      onTap: () => debugPrint('VS Code'),
                    ),
                    _buildQuickActionButton(
                      icon: Icons.photo,
                      label: 'Photos',
                      onTap: () => debugPrint('Photos'),
                    ),
                    _buildQuickActionButton(
                      icon: Icons.music_note,
                      label: 'Music',
                      onTap: () => debugPrint('Music'),
                    ),
                    _buildQuickActionButton(
                      icon: Icons.videocam,
                      label: 'Camera',
                      onTap: () => debugPrint('Camera'),
                    ),
                    _buildQuickActionButton(
                      icon: Icons.email,
                      label: 'Mail',
                      onTap: () => debugPrint('Mail'),
                    ),
                    _buildQuickActionButton(
                      icon: Icons.calculate,
                      label: 'Calculator',
                      onTap: () => debugPrint('Calculator'),
                    ),
                    _buildQuickActionButton(
                      icon: Icons.note_add,
                      label: 'Notepad',
                      onTap: () => debugPrint('Notepad'),
                    ),
                    _buildQuickActionButton(
                      icon: Icons.sports_esports,
                      label: 'Games',
                      onTap: () => debugPrint('Games'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Middle section (left panel + right grid)
          Expanded(
            flex: 4,
            child: Row(
              children: <Widget>[
                // Left tall panel
                Expanded(
                  flex: 1,
                  child: DashboardSection(
                    title: 'System Monitor',
                    color: Colors.green.shade50,
                    onTap: () => debugPrint('System Monitor tapped'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildSystemInfo('CPU Usage', '45%'),
                        const SizedBox(height: 12),
                        _buildSystemInfo('Memory', '6.2GB / 16GB'),
                        const SizedBox(height: 12),
                        _buildSystemInfo('Storage', '512GB / 1TB'),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Performance\nGraph',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Right 2x2 grid
                Expanded(
                  flex: 1,
                  child: Column(
                    children: <Widget>[
                      // Top row of right grid
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: DashboardSection(
                                title: 'Weather',
                                color: Colors.orange.shade50,
                                onTap: () => debugPrint('Weather tapped'),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.wb_sunny,
                                      size: 32,
                                      color: Colors.orange.shade600,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      '22°C',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text('Sunny'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DashboardSection(
                                title: 'Time',
                                color: Colors.purple.shade50,
                                onTap: () => debugPrint('Time tapped'),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.access_time,
                                      size: 32,
                                      color: Colors.purple.shade600,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      TimeOfDay.now().format(context),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      DateTime.now().toString().split(' ')[0],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Bottom row of right grid
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: DashboardSection(
                                title: 'Apps',
                                color: Colors.red.shade50,
                                onTap: () => debugPrint('Apps tapped'),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.apps,
                                      size: 32,
                                      color: Colors.red.shade600,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      '24',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text('Installed'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DashboardSection(
                                title: 'Notes',
                                color: Colors.yellow.shade50,
                                onTap: () => debugPrint('Notes tapped'),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.note,
                                      size: 32,
                                      color: Colors.yellow.shade700,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      '5',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text('Notes'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Bottom section (two equal panels)
          Expanded(
            flex: 2,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: DashboardSection(
                    title: 'Recent Files',
                    color: Colors.indigo.shade50,
                    onTap: () => debugPrint('Recent Files tapped'),
                    child: ListView(
                      children: <Widget>[
                        _buildFileItem(
                          'project_report.pdf',
                          Icons.picture_as_pdf,
                        ),
                        _buildFileItem('presentation.pptx', Icons.slideshow),
                        _buildFileItem('budget.xlsx', Icons.table_chart),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DashboardSection(
                    title: 'Favorites',
                    color: Colors.teal.shade50,
                    onTap: () => debugPrint('Favorites tapped'),
                    child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: <Widget>[
                        _buildFavoriteApp('VS Code', Icons.code),
                        _buildFavoriteApp('Chrome', Icons.web),
                        _buildFavoriteApp('Spotify', Icons.music_note),
                        _buildFavoriteApp('Discord', Icons.chat),
                        _buildFavoriteApp('Steam', Icons.sports_esports),
                        _buildFavoriteApp('Photoshop', Icons.photo),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

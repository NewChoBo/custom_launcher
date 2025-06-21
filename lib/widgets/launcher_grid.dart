import 'package:flutter/material.dart';
import 'package:custom_launcher/models/launcher_item.dart';
import 'package:custom_launcher/models/app_settings.dart';
import 'package:custom_launcher/widgets/launcher_item_widget.dart';

/// Widget for displaying launcher items in various layouts
class LauncherGrid extends StatelessWidget {
  final List<LauncherItem> items;
  final AppSettings settings;
  const LauncherGrid({super.key, required this.items, required this.settings});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    switch (settings.layoutMode) {
      case LauncherLayoutMode.grid:
        return _buildGridLayout();
      case LauncherLayoutMode.horizontalList:
        return _buildHorizontalList();
      case LauncherLayoutMode.verticalList:
        return _buildVerticalList();
      case LauncherLayoutMode.freeform:
        return _buildFreeformLayout();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.apps,
            size: 64,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No launcher items configured',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some apps or URLs to get started',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridLayout() {
    return Padding(
      padding: EdgeInsets.all(settings.itemSpacing),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: settings.gridColumns,
          crossAxisSpacing: settings.itemSpacing,
          mainAxisSpacing: settings.itemSpacing,
          childAspectRatio: 1.0,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return LauncherItemWidget(item: items[index], settings: settings);
        },
      ),
    );
  }

  Widget _buildHorizontalList() {
    return Padding(
      padding: EdgeInsets.all(settings.itemSpacing),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) =>
            SizedBox(width: settings.itemSpacing),
        itemBuilder: (context, index) {
          return SizedBox(
            width: settings.iconSize + 32, // Icon size + padding
            child: LauncherItemWidget(item: items[index], settings: settings),
          );
        },
      ),
    );
  }

  Widget _buildVerticalList() {
    return Padding(
      padding: EdgeInsets.all(settings.itemSpacing),
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) =>
            SizedBox(height: settings.itemSpacing),
        itemBuilder: (context, index) {
          return LauncherItemWidget(item: items[index], settings: settings);
        },
      ),
    );
  }

  Widget _buildFreeformLayout() {
    return Stack(
      children: items.map((item) {
        return Positioned(
          left: item.position.x,
          top: item.position.y,
          child: LauncherItemWidget(item: item, settings: settings),
        );
      }).toList(),
    );
  }
}

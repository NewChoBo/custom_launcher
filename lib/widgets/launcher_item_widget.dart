import 'package:flutter/material.dart';
import 'package:custom_launcher/models/launcher_item.dart';
import 'package:custom_launcher/models/app_settings.dart';
import 'package:custom_launcher/services/launcher_service.dart';

/// Widget for displaying a single launcher item
class LauncherItemWidget extends StatefulWidget {
  final LauncherItem item;
  final AppSettings settings;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  const LauncherItemWidget({
    super.key,
    required this.item,
    required this.settings,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  State<LauncherItemWidget> createState() => _LauncherItemWidgetState();
}

class _LauncherItemWidgetState extends State<LauncherItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.settings.clickBehavior == ClickBehavior.singleClick
            ? () => _handleLaunch()
            : widget.onTap,
        onDoubleTap: widget.settings.clickBehavior == ClickBehavior.doubleClick
            ? () => _handleLaunch()
            : widget.onDoubleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: _isHovered
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  )
                : null,
          ),
          padding: const EdgeInsets.all(8),
          child: _buildItemContent(),
        ),
      ),
    );
  }

  Widget _buildItemContent() {
    switch (widget.settings.textPosition) {
      case TextPosition.above:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.settings.showText) _buildText(),
            if (widget.settings.showIcons) _buildIcon(),
          ],
        );
      case TextPosition.below:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.settings.showIcons) _buildIcon(),
            if (widget.settings.showText) _buildText(),
          ],
        );
      case TextPosition.left:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.settings.showText) _buildText(),
            if (widget.settings.showIcons) const SizedBox(width: 8),
            if (widget.settings.showIcons) _buildIcon(),
          ],
        );
      case TextPosition.right:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.settings.showIcons) _buildIcon(),
            if (widget.settings.showIcons && widget.settings.showText)
              const SizedBox(width: 8),
            if (widget.settings.showText) _buildText(),
          ],
        );
      case TextPosition.none:
        return widget.settings.showIcons ? _buildIcon() : Container();
    }
  }

  Widget _buildIcon() {
    return Container(
      width: widget.settings.iconSize,
      height: widget.settings.iconSize,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Icon(
        _getItemIcon(),
        size: widget.settings.iconSize * 0.6,
        color: Colors.white.withValues(alpha: 0.9),
      ),
    );
  }

  Widget _buildText() {
    if (!widget.settings.showText) return const SizedBox.shrink();

    return Container(
      constraints: BoxConstraints(maxWidth: widget.settings.iconSize * 1.5),
      child: Text(
        widget.item.name,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }

  IconData _getItemIcon() {
    if (widget.item.isExecutable) {
      // Return appropriate icon based on file type
      final path = widget.item.path.toLowerCase();
      if (path.contains('notepad')) return Icons.edit_note;
      if (path.contains('calc')) return Icons.calculate;
      if (path.contains('code')) return Icons.code;
      if (path.contains('chrome') || path.contains('browser')) return Icons.web;
      return Icons.apps; // Default executable icon
    } else if (widget.item.isUrl) {
      return Icons.public; // Web icon for URLs
    }
    return Icons.help_outline; // Unknown type
  }

  Future<void> _handleLaunch() async {
    try {
      final success = await LauncherService.launchItem(widget.item);

      // Check if widget is still mounted after async operation
      if (!mounted) return;

      if (success) {
        // Update last used time
        // Note: This would typically update the settings and save them
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Launched ${widget.item.name}'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to launch ${widget.item.name}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Check if widget is still mounted after potential error
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

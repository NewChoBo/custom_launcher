import 'package:flutter/material.dart';

class LayoutEditorToolbar extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback onEditModeToggle;
  final VoidCallback onPreviewModeToggle;
  final VoidCallback onSaveLayout;
  final VoidCallback onResetLayout;

  const LayoutEditorToolbar({
    super.key,
    required this.isEditMode,
    required this.onEditModeToggle,
    required this.onPreviewModeToggle,
    required this.onSaveLayout,
    required this.onResetLayout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Visual Layout Editor',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          ToggleButtons(
            isSelected: [isEditMode, !isEditMode],
            onPressed: (index) {
              if (index == 0) {
                onEditModeToggle();
              } else {
                onPreviewModeToggle();
              }
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility),
                    SizedBox(width: 8),
                    Text('Preview'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: onSaveLayout,
            icon: const Icon(Icons.save),
            label: const Text('Save Layout'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: onResetLayout,
            icon: const Icon(Icons.restore),
            label: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

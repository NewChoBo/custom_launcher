import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_launcher/features/launcher/domain/entities/layout_config.dart';
import 'package:custom_launcher/core/providers/app_providers.dart';

class LayoutPropertiesPanel extends ConsumerWidget {
  final String? selectedElementPath;
  final LayoutElement? selectedElement;
  final Function(String key, dynamic value) onPropertyUpdate;

  const LayoutPropertiesPanel({
    super.key,
    required this.selectedElementPath,
    required this.selectedElement,
    required this.onPropertyUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Properties',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (selectedElementPath != null && selectedElement != null) ...[
              _buildElementProperties(context),
            ] else ...[
              Text(
                'Select an element to view properties',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildElementProperties(BuildContext context) {
    if (selectedElement == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Type: ${selectedElement!.type}',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Path: $selectedElementPath',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Properties:',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._buildEditableProperties(context),
      ],
    );
  }

  List<Widget> _buildEditableProperties(BuildContext context) {
    final List<Widget> propertyWidgets = [];
    final Map<String, dynamic> properties = selectedElement!.properties ?? {};

    // Type-specific property editors
    switch (selectedElement!.type) {
      case 'expanded':
        propertyWidgets.add(_buildFlexEditor(context, properties));
        break;
      case 'custom_card':
        propertyWidgets.add(_buildAppIdEditor(context, properties));
        propertyWidgets.add(_buildAppNameEditor(context, properties));
        break;
      case 'text':
        propertyWidgets.add(_buildTextEditor(context, properties));
        propertyWidgets.add(_buildFontSizeEditor(context, properties));
        break;
      case 'sizedbox':
        propertyWidgets.add(
          _buildDimensionEditor(context, properties, 'width', 'Width'),
        );
        propertyWidgets.add(
          _buildDimensionEditor(context, properties, 'height', 'Height'),
        );
        break;
      case 'container':
        propertyWidgets.add(
          _buildDimensionEditor(context, properties, 'width', 'Width'),
        );
        propertyWidgets.add(
          _buildDimensionEditor(context, properties, 'height', 'Height'),
        );
        propertyWidgets.add(_buildPaddingEditor(context, properties));
        propertyWidgets.add(_buildColorEditor(context, properties));
        propertyWidgets.add(_buildBorderRadiusEditor(context, properties));
        break;
      case 'column':
      case 'row':
        propertyWidgets.add(_buildSpacingEditor(context, properties));
        propertyWidgets.add(_buildMainAxisAlignmentEditor(context, properties));
        propertyWidgets.add(
          _buildCrossAxisAlignmentEditor(context, properties),
        );
        break;
    }

    // Common properties for all elements
    if (properties.isNotEmpty) {
      propertyWidgets.add(const SizedBox(height: 16));
      propertyWidgets.add(
        Text(
          'All Properties:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      );
      propertyWidgets.add(const SizedBox(height: 8));

      // Show read-only view of all properties
      for (final entry in properties.entries) {
        propertyWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.value.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return propertyWidgets;
  }

  Widget _buildPropertyCard(String title, Widget child) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildFlexEditor(
    BuildContext context,
    Map<String, dynamic> properties,
  ) {
    final int currentFlex = properties['flex'] as int? ?? 1;

    return _buildPropertyCard(
      'Flex',
      Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: currentFlex.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: currentFlex.toString(),
                  onChanged: (value) {
                    onPropertyUpdate('flex', value.toInt());
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 50,
                child: Text(
                  currentFlex.toString(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppIdEditor(
    BuildContext context,
    Map<String, dynamic> properties,
  ) {
    final String currentAppId = properties['app_id'] as String? ?? '';

    return _buildPropertyCard(
      'App ID',
      Consumer(
        builder: (context, ref, child) {
          final appListAsync = ref.watch(appListNotifierProvider);

          return appListAsync.when(
            data: (apps) {
              String? selectedValue = currentAppId;
              if (selectedValue.isNotEmpty &&
                  !apps.any((app) => app.id == selectedValue)) {
                selectedValue = null;
              }

              return DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  hintText: 'Select an app',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                isExpanded: true,
                menuMaxHeight: 300,
                items: apps.map<DropdownMenuItem<String>>((app) {
                  return DropdownMenuItem<String>(
                    value: app.id,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                            ),
                            child:
                                app.imagePath != null &&
                                    app.imagePath!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.asset(
                                      app.imagePath!,
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.apps,
                                              size: 16,
                                            );
                                          },
                                    ),
                                  )
                                : const Icon(Icons.apps, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              app.title,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onPropertyUpdate('app_id', value);
                  }
                },
              );
            },
            loading: () => const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (error, stack) => Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Error loading apps',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppNameEditor(
    BuildContext context,
    Map<String, dynamic> properties,
  ) {
    final String currentName = properties['app_name'] as String? ?? '';

    return _buildPropertyCard(
      'App Name',
      TextFormField(
        initialValue: currentName,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          hintText: 'Enter app name',
        ),
        onChanged: (value) {
          onPropertyUpdate('app_name', value);
        },
      ),
    );
  }

  Widget _buildTextEditor(
    BuildContext context,
    Map<String, dynamic> properties,
  ) {
    final String currentText = properties['text'] as String? ?? '';

    return _buildPropertyCard(
      'Text',
      TextFormField(
        initialValue: currentText,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          hintText: 'Enter text',
        ),
        onChanged: (value) {
          onPropertyUpdate('text', value);
        },
      ),
    );
  }

  Widget _buildFontSizeEditor(
    BuildContext context,
    Map<String, dynamic> properties,
  ) {
    final double currentSize =
        (properties['font_size'] as num?)?.toDouble() ?? 14.0;

    return _buildPropertyCard(
      'Font Size',
      Row(
        children: [
          Expanded(
            child: Slider(
              value: currentSize,
              min: 8,
              max: 48,
              divisions: 40,
              label: currentSize.toStringAsFixed(0),
              onChanged: (value) {
                onPropertyUpdate('font_size', value);
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              currentSize.toStringAsFixed(0),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionEditor(
    BuildContext context,
    Map<String, dynamic> properties,
    String propertyKey,
    String label,
  ) {
    final dynamic currentValue = properties[propertyKey];
    final double currentNumber = (currentValue as num?)?.toDouble() ?? 100.0;

    return _buildPropertyCard(
      label,
      Row(
        children: [
          Expanded(
            child: Slider(
              value: currentNumber,
              min: 10,
              max: 500,
              divisions: 49,
              label: currentNumber.toStringAsFixed(0),
              onChanged: (value) {
                onPropertyUpdate(propertyKey, value);
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              currentNumber.toStringAsFixed(0),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpacingEditor(
    BuildContext context,
    Map<String, dynamic> properties,
  ) {
    final double currentSpacing =
        (properties['spacing'] as num?)?.toDouble() ?? 8.0;

    return _buildPropertyCard(
      'Spacing',
      Row(
        children: [
          Expanded(
            child: Slider(
              value: currentSpacing,
              min: 0,
              max: 50,
              divisions: 50,
              label: currentSpacing.toStringAsFixed(0),
              onChanged: (value) {
                onPropertyUpdate('spacing', value);
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              currentSpacing.toStringAsFixed(0),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainAxisAlignmentEditor(
    BuildContext context,
    Map<String, dynamic> properties,
  ) {
    final String currentAlignment =
        properties['main_axis_alignment'] as String? ?? 'start';

    return _buildPropertyCard(
      'Main Axis Alignment',
      DropdownButtonFormField<String>(
        value: currentAlignment,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: const [
          DropdownMenuItem(value: 'start', child: Text('Start')),
          DropdownMenuItem(value: 'center', child: Text('Center')),
          DropdownMenuItem(value: 'end', child: Text('End')),
          DropdownMenuItem(value: 'spaceBetween', child: Text('Space Between')),
          DropdownMenuItem(value: 'spaceAround', child: Text('Space Around')),
          DropdownMenuItem(value: 'spaceEvenly', child: Text('Space Evenly')),
        ],
        onChanged: (value) {
          if (value != null) {
            onPropertyUpdate('main_axis_alignment', value);
          }
        },
      ),
    );
  }

  Widget _buildCrossAxisAlignmentEditor(
    BuildContext context,
    Map<String, dynamic> properties,
  ) {
    final String currentAlignment =
        properties['cross_axis_alignment'] as String? ?? 'start';

    return _buildPropertyCard(
      'Cross Axis Alignment',
      DropdownButtonFormField<String>(
        value: currentAlignment,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: const [
          DropdownMenuItem(value: 'start', child: Text('Start')),
          DropdownMenuItem(value: 'center', child: Text('Center')),
          DropdownMenuItem(value: 'end', child: Text('End')),
          DropdownMenuItem(value: 'stretch', child: Text('Stretch')),
        ],
        onChanged: (value) {
          if (value != null) {
            onPropertyUpdate('cross_axis_alignment', value);
          }
        },
      ),
    );
  }

  Widget _buildPaddingEditor(
    BuildContext context,
    Map<String, dynamic> properties,
  ) {
    final Map<String, dynamic>? paddingMap =
        properties['padding'] as Map<String, dynamic>?;
    final double currentPadding =
        (paddingMap?['all'] as num?)?.toDouble() ?? 8.0;

    return _buildPropertyCard(
      'Padding',
      Row(
        children: [
          Expanded(
            child: Slider(
              value: currentPadding,
              min: 0,
              max: 50,
              divisions: 50,
              label: currentPadding.toStringAsFixed(0),
              onChanged: (value) {
                onPropertyUpdate('padding', {'all': value});
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              currentPadding.toStringAsFixed(0),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorEditor(
    BuildContext context,
    Map<String, dynamic> properties,
  ) {
    final Map<String, dynamic>? decorationMap =
        properties['decoration'] as Map<String, dynamic>?;
    final String currentColor = decorationMap?['color'] as String? ?? '#FFFFFF';

    return _buildPropertyCard(
      'Background Color',
      TextFormField(
        initialValue: currentColor,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          hintText: '#FFFFFF',
          prefixText: '#',
        ),
        onChanged: (value) {
          final decorationValue = Map<String, dynamic>.from(
            decorationMap ?? {},
          );
          decorationValue['color'] = value.startsWith('#') ? value : '#$value';
          onPropertyUpdate('decoration', decorationValue);
        },
      ),
    );
  }

  Widget _buildBorderRadiusEditor(
    BuildContext context,
    Map<String, dynamic> properties,
  ) {
    final Map<String, dynamic>? decorationMap =
        properties['decoration'] as Map<String, dynamic>?;
    final double currentRadius =
        (decorationMap?['border_radius'] as num?)?.toDouble() ?? 0.0;

    return _buildPropertyCard(
      'Border Radius',
      Row(
        children: [
          Expanded(
            child: Slider(
              value: currentRadius,
              min: 0,
              max: 50,
              divisions: 50,
              label: currentRadius.toStringAsFixed(0),
              onChanged: (value) {
                final decorationValue = Map<String, dynamic>.from(
                  decorationMap ?? {},
                );
                decorationValue['border_radius'] = value;
                onPropertyUpdate('decoration', decorationValue);
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              currentRadius.toStringAsFixed(0),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

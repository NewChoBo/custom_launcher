import 'package:flutter/material.dart';

/// Settings UI components helper class
/// 설정 페이지에서 사용되는 공통 UI 컴포넌트들을 관리하는 헬퍼 클래스
class SettingsHelpers {
  /// Section title builder
  static Widget buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Color picker widget
  static Widget buildColorPicker(
    BuildContext context,
    String title,
    String currentColor,
    Function(String) onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(currentColor),
      trailing: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _parseColor(currentColor),
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      onTap: () => _showColorPicker(context, currentColor, onChanged),
    );
  }

  /// Opacity slider widget
  static Widget buildOpacitySlider(
    String title,
    double value,
    Function(double) onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Slider(
        value: value,
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: '${(value * 100).round()}%',
        onChanged: onChanged,
      ),
      trailing: Text('${(value * 100).round()}%'),
    );
  }

  /// Text input field widget
  static Widget buildTextInputField(
    String title,
    String value,
    Function(String) onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: TextField(
        controller: TextEditingController(text: value),
        onChanged: onChanged,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  /// Dropdown widget
  static Widget buildDropdown(
    String title,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    // 현재 값이 옵션에 없으면 첫 번째 옵션을 기본값으로 사용
    final String safeValue = options.contains(value) ? value : options.first;

    return ListTile(
      title: Text(title),
      subtitle: DropdownButtonFormField<String>(
        value: safeValue,
        items: options.map((option) {
          return DropdownMenuItem<String>(value: option, child: Text(option));
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  /// Number input field widget
  static Widget buildNumberField(
    String title,
    int value,
    Function(int) onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: TextField(
        controller: TextEditingController(text: value.toString()),
        onChanged: (text) {
          final intValue = int.tryParse(text);
          if (intValue != null) {
            onChanged(intValue);
          }
        },
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  /// Parse hex color string to Color object
  static Color _parseColor(String hexString) {
    if (hexString.isEmpty) return Colors.transparent;
    final String hex = hexString.replaceFirst('#', '');
    if (hex.length != 6) return Colors.transparent;
    final int argbValue = int.parse('FF$hex', radix: 16);
    return Color(argbValue);
  }

  /// Show color picker dialog
  static void _showColorPicker(
    BuildContext context,
    String currentColor,
    Function(String) onChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: currentColor),
                onChanged: onChanged,
                decoration: const InputDecoration(
                  labelText: 'Hex Color (e.g., #FF0000)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Preset Colors:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                      '#FF0000',
                      '#00FF00',
                      '#0000FF',
                      '#FFFF00',
                      '#FF00FF',
                      '#00FFFF',
                      '#FFFFFF',
                      '#000000',
                      '#808080',
                      '#FFA500',
                      '#800080',
                      '#008000',
                    ].map((color) {
                      return GestureDetector(
                        onTap: () {
                          onChanged(color);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _parseColor(color),
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

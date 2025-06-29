import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FrameLayout extends StatefulWidget {
  const FrameLayout({super.key});
  @override
  State<FrameLayout> createState() => _FrameLayoutState();
}

class _FrameLayoutState extends State<FrameLayout> {
  Map<String, dynamic>? layoutConfig;

  @override
  void initState() {
    super.initState();
    _loadLayout();
  }

  Future<void> _loadLayout() async {
    final String jsonStr = await rootBundle.loadString(
      'assets/config/layout.json',
    );
    setState(() {
      layoutConfig = json.decode(jsonStr);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (layoutConfig == null || layoutConfig!.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return _buildFromJson(layoutConfig!);
  }

  Widget _buildFromJson(Map<String, dynamic> node) {
    switch (node['type']) {
      case 'row':
        return Row(
          children: (node['children'] as List)
              .map<Widget>((child) => _buildFromJson(child))
              .toList(),
        );
      case 'column':
        return Expanded(
          flex: node['flex'] ?? 1,
          child: Column(
            children: (node['children'] as List)
                .map<Widget>((child) => _buildFromJson(child))
                .toList(),
          ),
        );
      case 'container':
        return Expanded(
          flex: node['flex'] ?? 1,
          child: Container(color: _parseColor(node['color'])),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Color _parseColor(String? hex) {
    if (hex == null) return Colors.transparent;
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}

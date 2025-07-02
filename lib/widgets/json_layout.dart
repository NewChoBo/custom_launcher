import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget that displays JSON data from app_settings.json
/// Shows the current configuration in a readable tree format
class JsonLayout extends StatefulWidget {
  const JsonLayout({super.key});

  @override
  State<JsonLayout> createState() => _JsonLayoutState();
}

class _JsonLayoutState extends State<JsonLayout> {
  Map<String, dynamic>? _jsonData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  /// Load JSON data from assets/config/app_settings.json
  Future<void> _loadJsonData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final String jsonString = await rootBundle.loadString(
        'assets/config/app_settings.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      setState(() {
        _jsonData = jsonData;
        _isLoading = false;
      });

      debugPrint('JSON data loaded successfully: ${jsonData.keys}');
    } catch (e) {
      setState(() {
        _error = 'Failed to load JSON: $e';
        _isLoading = false;
      });
      debugPrint('Error loading JSON: $e');
    }
  }

  /// Build a widget tree from JSON data
  Widget _buildJsonTree(dynamic data, String key, int depth) {
    const double indentSize = 20.0;
    final Color backgroundColor = depth.isEven
        ? Colors.grey.withValues(alpha: 0.1)
        : Colors.blue.withValues(alpha: 0.05);

    if (data is Map<String, dynamic>) {
      return Container(
        margin: EdgeInsets.only(left: depth * indentSize, bottom: 4.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: ExpansionTile(
          title: Text(
            key,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
              fontSize: 16.0,
            ),
          ),
          subtitle: Text(
            '${data.length} items',
            style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
          ),
          initiallyExpanded: depth < 2,
          children: data.entries.map((MapEntry<String, dynamic> entry) {
            return _buildJsonTree(entry.value, entry.key, depth + 1);
          }).toList(),
        ),
      );
    } else if (data is List) {
      return Container(
        margin: EdgeInsets.only(left: depth * indentSize, bottom: 4.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: ExpansionTile(
          title: Text(
            key,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange[700],
              fontSize: 16.0,
            ),
          ),
          subtitle: Text(
            '${data.length} items',
            style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
          ),
          initiallyExpanded: depth < 2,
          children: data.asMap().entries.map((MapEntry<int, dynamic> entry) {
            return _buildJsonTree(entry.value, '[${entry.key}]', depth + 1);
          }).toList(),
        ),
      );
    } else {
      // Leaf node (primitive value)
      return Container(
        margin: EdgeInsets.only(left: depth * indentSize, bottom: 2.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Text(
                key,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.green[700],
                  fontSize: 14.0,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              flex: 3,
              child: SelectableText(
                data.toString(),
                style: TextStyle(
                  color: _getValueColor(data),
                  fontSize: 14.0,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  /// Get color based on value type
  Color _getValueColor(dynamic value) {
    if (value is String) {
      return Colors.red[600]!;
    } else if (value is num) {
      return Colors.blue[600]!;
    } else if (value is bool) {
      return Colors.purple[600]!;
    } else {
      return Colors.grey[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 16.0),
            Text('Loading JSON data...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.error, color: Colors.red, size: 48.0),
            const SizedBox(height: 16.0),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _loadJsonData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_jsonData == null || _jsonData!.isEmpty) {
      return const Center(child: Text('No JSON data available'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings JSON'),
        backgroundColor: Colors.blue[50],
        foregroundColor: Colors.blue[700],
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadJsonData,
            tooltip: 'Reload JSON',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.info, color: Colors.blue[700]),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'Current app settings loaded from assets/config/app_settings.json',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            ..._jsonData!.entries.map((MapEntry<String, dynamic> entry) {
              return _buildJsonTree(entry.value, entry.key, 0);
            }).toList(),
          ],
        ),
      ),
    );
  }
}

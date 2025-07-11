import 'dart:convert';

class LayoutConfig {
  final LayoutElement layout;

  const LayoutConfig({required this.layout});

  factory LayoutConfig.fromMap(Map<String, dynamic> map) {
    return LayoutConfig(
      layout: LayoutElement.fromMap(map['layout'] as Map<String, dynamic>),
    );
  }

  factory LayoutConfig.fromJson(String source) {
    return LayoutConfig.fromMap(json.decode(source) as Map<String, dynamic>);
  }
}

class LayoutElement {
  final String type;
  final Map<String, dynamic>? properties;
  final List<LayoutElement>? children;
  final LayoutElement? child;

  const LayoutElement({
    required this.type,
    this.properties,
    this.children,
    this.child,
  });

  factory LayoutElement.fromMap(Map<String, dynamic> map) {
    return LayoutElement(
      type: map['type'] as String,
      properties: Map<String, dynamic>.from(map)
        ..remove('type')
        ..remove('children')
        ..remove('child'),
      children: map['children'] != null
          ? (map['children'] as List<dynamic>)
                .map<LayoutElement>((dynamic x) => LayoutElement.fromMap(x as Map<String, dynamic>))
                .toList()
          : null,
      child: map['child'] != null
          ? LayoutElement.fromMap(map['child'] as Map<String, dynamic>)
          : null,
    );
  }

  T? getProperty<T>(String key, [T? defaultValue]) {
    if (properties == null) return defaultValue;
    final dynamic value = properties![key];
    if (value is T) return value;
    return defaultValue;
  }

  T? getNestedProperty<T>(String path, [T? defaultValue]) {
    if (properties == null) return defaultValue;

    final List<String> keys = path.split('.');
    dynamic current = properties;

    for (final String key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return defaultValue;
      }
    }

    return current is T ? current : defaultValue;
  }
}

class LayoutStyle {
  final double? fontSize;
  final String? fontWeight;
  final String? color;
  final String? textAlign;

  const LayoutStyle({
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
  });

  factory LayoutStyle.fromMap(Map<String, dynamic> map) {
    return LayoutStyle(
      fontSize: (map['fontSize'] as num?)?.toDouble(),
      fontWeight: map['fontWeight'] as String?,
      color: map['color'] as String?,
      textAlign: map['textAlign'] as String?,
    );
  }
}

class LayoutPadding {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double? all;

  const LayoutPadding({this.top, this.bottom, this.left, this.right, this.all});

  factory LayoutPadding.fromMap(Map<String, dynamic> map) {
    return LayoutPadding(
      top: (map['top'] as num?)?.toDouble(),
      bottom: (map['bottom'] as num?)?.toDouble(),
      left: (map['left'] as num?)?.toDouble(),
      right: (map['right'] as num?)?.toDouble(),
      all: (map['all'] as num?)?.toDouble(),
    );
  }
}

class LayoutDecoration {
  final String? color;
  final double? borderRadius;

  const LayoutDecoration({this.color, this.borderRadius});

  factory LayoutDecoration.fromMap(Map<String, dynamic> map) {
    return LayoutDecoration(
      color: map['color'] as String?,
      borderRadius: (map['borderRadius'] as num?)?.toDouble(),
    );
  }
}

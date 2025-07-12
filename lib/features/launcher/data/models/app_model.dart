import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'app_model.g.dart';

@JsonSerializable()
class AppModel extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String? imagePath;
  final String? executablePath;
  final List<String>? arguments;

  final String? customBackgroundImage;
  final Map<String, dynamic>? customSettings;
  final bool isEnabled;
  final DateTime? lastLaunched;
  final String? description;
  final List<String>? tags;
  final int launchCount;
  final Map<String, dynamic>? metadata;

  const AppModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imagePath,
    this.executablePath,
    this.arguments,
    this.customBackgroundImage,
    this.customSettings,
    this.isEnabled = true,
    this.lastLaunched,
    this.description,
    this.tags,
    this.launchCount = 0,
    this.metadata,
  });

  factory AppModel.fromJson(Map<String, dynamic> json) {
    T? safeCast<T>(dynamic value) => value is T ? value : null;

    return AppModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imagePath: safeCast<String>(json['imagePath']),
      executablePath: safeCast<String>(json['executablePath']),
      arguments: safeCast<List>(json['arguments'])?.cast<String>(),

      customBackgroundImage: safeCast<String>(json['customBackgroundImage']),
      customSettings: safeCast<Map<String, dynamic>>(json['customSettings']),
      isEnabled: safeCast<bool>(json['isEnabled']) ?? true,
      lastLaunched: json['lastLaunched'] != null
          ? DateTime.tryParse(json['lastLaunched'] as String)
          : null,
      description: safeCast<String>(json['description']),
      tags: safeCast<List>(json['tags'])?.cast<String>(),
      launchCount: safeCast<int>(json['launchCount']) ?? 0,
      metadata: safeCast<Map<String, dynamic>>(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() => _$AppModelToJson(this);

  AppModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imagePath,
    String? executablePath,
    List<String>? arguments,
    String? customBackgroundImage,
    Map<String, dynamic>? customSettings,
    bool? isEnabled,
    DateTime? lastLaunched,
    String? description,
    List<String>? tags,
    int? launchCount,
    Map<String, dynamic>? metadata,
  }) {
    return AppModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imagePath: imagePath ?? this.imagePath,
      executablePath: executablePath ?? this.executablePath,
      arguments: arguments ?? this.arguments,
      customBackgroundImage:
          customBackgroundImage ?? this.customBackgroundImage,
      customSettings: customSettings ?? this.customSettings,
      isEnabled: isEnabled ?? this.isEnabled,
      lastLaunched: lastLaunched ?? this.lastLaunched,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      launchCount: launchCount ?? this.launchCount,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    imagePath,
    executablePath,
    arguments,
    customBackgroundImage,
    customSettings,
    isEnabled,
    lastLaunched,
    description,
    tags,
    launchCount,
    metadata,
  ];
}

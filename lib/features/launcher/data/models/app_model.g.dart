// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppModel _$AppModelFromJson(Map<String, dynamic> json) => AppModel(
  id: json['id'] as String,
  title: json['title'] as String,
  subtitle: json['subtitle'] as String,
  imagePath: json['imagePath'] as String?,
  executablePath: json['executablePath'] as String?,
  arguments: (json['arguments'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  customBackgroundImage: json['customBackgroundImage'] as String?,
  customSettings: json['customSettings'] as Map<String, dynamic>?,
  isEnabled: json['isEnabled'] as bool? ?? true,
  lastLaunched: json['lastLaunched'] == null
      ? null
      : DateTime.parse(json['lastLaunched'] as String),
  description: json['description'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  launchCount: (json['launchCount'] as num?)?.toInt() ?? 0,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AppModelToJson(AppModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'imagePath': instance.imagePath,
  'executablePath': instance.executablePath,
  'arguments': instance.arguments,
  'customBackgroundImage': instance.customBackgroundImage,
  'customSettings': instance.customSettings,
  'isEnabled': instance.isEnabled,
  'lastLaunched': instance.lastLaunched?.toIso8601String(),
  'description': instance.description,
  'tags': instance.tags,
  'launchCount': instance.launchCount,
  'metadata': instance.metadata,
};

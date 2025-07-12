// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageCropModel _$ImageCropModelFromJson(Map<String, dynamic> json) =>
    ImageCropModel(
      matrixData: (json['matrixData'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$ImageCropModelToJson(ImageCropModel instance) =>
    <String, dynamic>{'matrixData': instance.matrixData};

AppModel _$AppModelFromJson(Map<String, dynamic> json) => AppModel(
  id: json['id'] as String,
  title: json['title'] as String,
  subtitle: json['subtitle'] as String,
  imagePath: json['imagePath'] as String?,
  executablePath: json['executablePath'] as String?,
  arguments: (json['arguments'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  imageCrop: json['imageCrop'] == null
      ? null
      : ImageCropModel.fromJson(json['imageCrop'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AppModelToJson(AppModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'imagePath': instance.imagePath,
  'executablePath': instance.executablePath,
  'arguments': instance.arguments,
  'imageCrop': instance.imageCrop,
};

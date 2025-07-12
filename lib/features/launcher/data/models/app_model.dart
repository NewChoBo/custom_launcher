import 'package:json_annotation/json_annotation.dart';

part 'app_model.g.dart';

@JsonSerializable()
class ImageCropModel {
  final List<double>? matrixData;

  ImageCropModel({
    this.matrixData,
  });

  factory ImageCropModel.fromJson(Map<String, dynamic> json) =>
      _$ImageCropModelFromJson(json);
  Map<String, dynamic> toJson() => _$ImageCropModelToJson(this);
}

@JsonSerializable()
class AppModel {
  final String id;
  final String title;
  final String subtitle;
  final String? imagePath;
  final String? executablePath;
  final List<String>? arguments;
  final ImageCropModel? imageCrop;

  AppModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imagePath,
    this.executablePath,
    this.arguments,
    this.imageCrop,
  });

  AppModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imagePath,
    String? executablePath,
    List<String>? arguments,
    ImageCropModel? imageCrop,
  }) {
    return AppModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imagePath: imagePath ?? this.imagePath,
      executablePath: executablePath ?? this.executablePath,
      arguments: arguments ?? this.arguments,
      imageCrop: imageCrop ?? this.imageCrop,
    );
  }

  factory AppModel.fromJson(Map<String, dynamic> json) =>
      _$AppModelFromJson(json);
  Map<String, dynamic> toJson() => _$AppModelToJson(this);
}
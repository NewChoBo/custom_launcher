import 'package:json_annotation/json_annotation.dart';

part 'app_model.g.dart';

@JsonSerializable()
class AppModel {
  final String id;
  final String title;
  final String subtitle;
  final String? imagePath;
  final String? executablePath;
  final List<String>? arguments;

  AppModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imagePath,
    this.executablePath,
    this.arguments,
  });

  factory AppModel.fromJson(Map<String, dynamic> json) => _$AppModelFromJson(json);
  Map<String, dynamic> toJson() => _$AppModelToJson(this);
}

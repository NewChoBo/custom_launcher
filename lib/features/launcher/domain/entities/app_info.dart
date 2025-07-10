import 'package:equatable/equatable.dart';

class AppInfo extends Equatable {
  final String name;
  final String displayName;
  final String icon;
  final String description;
  final List<String> paths;

  const AppInfo({
    required this.name,
    required this.displayName,
    required this.icon,
    required this.description,
    required this.paths,
  });

  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String,
      paths: List<String>.from(json['paths'] as List),
    );
  }

  @override
  List<Object?> get props => [name, displayName, icon, description, paths];
}

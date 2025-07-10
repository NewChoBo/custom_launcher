import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:custom_launcher/features/launcher/data/models/app_model.dart';

import 'package:collection/collection.dart';

class AppDataRepository {
  List<AppModel> _apps = [];

  Future<void> loadAppData() async {
    final String response = await rootBundle.loadString('assets/config/app_data.json');
    final data = await json.decode(response);
    _apps = (data['apps'] as List).map((e) => AppModel.fromJson(e)).toList();
  }

  AppModel? getAppById(String id) {
    return _apps.firstWhereOrNull((app) => app.id == id);
  }
}

import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:custom_launcher/features/launcher/data/models/app_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppDataRepository extends AsyncNotifier<List<AppModel>> {
  static const String _fileName = 'app_data.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  Future<void> _initiateData() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        final String jsonString = await rootBundle.loadString(
          'assets/config/$_fileName',
        );
        await file.writeAsString(jsonString);
      }
    } catch (e) {
      // Handle error, e.g., log it or show a user-friendly message
      debugPrint('Error initiating data: $e');
      rethrow; // Re-throw to propagate the error to the AsyncValue
    }
  }

  @override
  Future<List<AppModel>> build() async {
    await _initiateData();
    try {
      final file = await _localFile;
      final String response = await file.readAsString();
      final data = json.decode(response);
      return (data['apps'] as List).map((e) => AppModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error loading app data: $e');
      rethrow;
    }
  }

  AppModel? getAppById(String id) {
    return state.value?.firstWhereOrNull((app) => app.id == id);
  }

  Future<void> updateApp(AppModel updatedApp) async {
    state = await AsyncValue.guard(() async {
      final currentApps = state.value ?? [];
      final updatedApps = List<AppModel>.from(currentApps);
      final index = updatedApps.indexWhere((app) => app.id == updatedApp.id);
      if (index != -1) {
        updatedApps[index] = updatedApp;
        await _saveData(updatedApps);
      }
      return updatedApps;
    });
  }

  Future<void> _saveData(List<AppModel> appsToSave) async {
    try {
      final file = await _localFile;
      final data = {'apps': appsToSave.map((e) => e.toJson()).toList()};
      await file.writeAsString(json.encode(data));
    } catch (e) {
      debugPrint('Error saving app data: $e');
      rethrow;
    }
  }
}

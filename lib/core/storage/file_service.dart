import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:custom_launcher/core/logging/logging.dart';
import 'package:custom_launcher/core/error/error.dart';

class FileService {
  static FileService? _instance;
  static FileService get instance => _instance ??= FileService._();

  FileService._();

  String? _appDataPath;

  Future<String> getAppDataPath() async {
    if (_appDataPath != null) return _appDataPath!;

    try {
      final directory = await getApplicationDocumentsDirectory();
      _appDataPath = '${directory.path}/custom_launcher';

      final appDir = Directory(_appDataPath!);
      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
        LogManager.info(
          'Created app data directory: $_appDataPath',
          tag: 'FileService',
        );
      }

      return _appDataPath!;
    } catch (e, stackTrace) {
      throw FileSystemError(
        message: 'Failed to get app data path',
        details: 'Error accessing application documents directory',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Map<String, dynamic>> readJsonFile(String fileName) async {
    try {
      final filePath = await _getFilePath(fileName);
      final file = File(filePath);

      if (!await file.exists()) {
        throw FileSystemError(
          message: 'File not found',
          filePath: filePath,
          details: 'The requested file does not exist',
        );
      }

      final content = await file.readAsString();
      final jsonData = json.decode(content) as Map<String, dynamic>;

      LogManager.debug('Read JSON file: $fileName', tag: 'FileService');
      return jsonData;
    } catch (e, stackTrace) {
      if (e is FileSystemError) rethrow;

      throw FileSystemError(
        message: 'Failed to read JSON file',
        filePath: fileName,
        details: 'Error reading or parsing JSON content',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> writeJsonFile(String fileName, Map<String, dynamic> data) async {
    try {
      final filePath = await _getFilePath(fileName);
      final file = File(filePath);

      if (await file.exists()) {
        await _createBackup(filePath);
      }

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      await file.writeAsString(jsonString);

      LogManager.info('Wrote JSON file: $fileName', tag: 'FileService');
    } catch (e, stackTrace) {
      throw FileSystemError(
        message: 'Failed to write JSON file',
        filePath: fileName,
        details: 'Error writing JSON content to file',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool> fileExists(String fileName) async {
    try {
      final filePath = await _getFilePath(fileName);
      return await File(filePath).exists();
    } catch (e) {
      LogManager.warn(
        'Error checking file existence: $fileName',
        tag: 'FileService',
        error: e,
      );
      return false;
    }
  }

  Future<void> deleteFile(String fileName) async {
    try {
      final filePath = await _getFilePath(fileName);
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        LogManager.info('Deleted file: $fileName', tag: 'FileService');
      } else {
        LogManager.warn('File does not exist: $fileName', tag: 'FileService');
      }
    } catch (e, stackTrace) {
      throw FileSystemError(
        message: 'Failed to delete file',
        filePath: fileName,
        details: 'Error deleting file',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<String>> listFiles({String? extension}) async {
    try {
      final appDataPath = await getAppDataPath();
      final directory = Directory(appDataPath);

      final files = await directory.list().toList();
      final fileNames = files
          .where((entity) => entity is File)
          .map((entity) => entity.path.split('/').last)
          .where((name) => extension == null || name.endsWith('.$extension'))
          .toList();

      LogManager.debug('Listed ${fileNames.length} files', tag: 'FileService');
      return fileNames;
    } catch (e, stackTrace) {
      throw FileSystemError(
        message: 'Failed to list files',
        details: 'Error listing files in app data directory',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _createBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final backupPath = '$filePath.backup';
        await file.copy(backupPath);
        LogManager.debug('Created backup: $backupPath', tag: 'FileService');
      }
    } catch (e) {
      LogManager.warn(
        'Failed to create backup for: $filePath',
        tag: 'FileService',
        error: e,
      );
    }
  }

  Future<String> _getFilePath(String fileName) async {
    final appDataPath = await getAppDataPath();
    return '$appDataPath/$fileName';
  }

  Future<void> restoreBackup(String fileName) async {
    try {
      final filePath = await _getFilePath(fileName);
      final backupPath = '$filePath.backup';
      final backupFile = File(backupPath);

      if (await backupFile.exists()) {
        await backupFile.copy(filePath);
        LogManager.info('Restored backup for: $fileName', tag: 'FileService');
      } else {
        throw FileSystemError(
          message: 'Backup file not found',
          filePath: backupPath,
          details: 'No backup file exists for restoration',
        );
      }
    } catch (e, stackTrace) {
      throw FileSystemError(
        message: 'Failed to restore backup',
        filePath: fileName,
        details: 'Error restoring backup file',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<int> getDirectorySize() async {
    try {
      final appDataPath = await getAppDataPath();
      final directory = Directory(appDataPath);

      int totalSize = 0;
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      LogManager.debug(
        'Directory size: ${totalSize ~/ 1024} KB',
        tag: 'FileService',
      );
      return totalSize;
    } catch (e) {
      LogManager.warn(
        'Failed to calculate directory size',
        tag: 'FileService',
        error: e,
      );
      return 0;
    }
  }

  Future<void> cleanupOldBackups({int keepDays = 7}) async {
    try {
      final appDataPath = await getAppDataPath();
      final directory = Directory(appDataPath);

      final cutoffTime = DateTime.now().subtract(Duration(days: keepDays));
      int deletedCount = 0;

      await for (final entity in directory.list()) {
        if (entity is File && entity.path.endsWith('.backup')) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffTime)) {
            await entity.delete();
            deletedCount++;
          }
        }
      }

      if (deletedCount > 0) {
        LogManager.info(
          'Cleaned up $deletedCount old backup files',
          tag: 'FileService',
        );
      }
    } catch (e) {
      LogManager.warn(
        'Failed to cleanup old backups',
        tag: 'FileService',
        error: e,
      );
    }
  }
}

final fileService = FileService.instance;

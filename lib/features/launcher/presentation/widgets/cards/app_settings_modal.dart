import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_launcher/features/launcher/data/models/app_model.dart';
import 'package:custom_launcher/core/providers/app_providers.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/cards/image_selection_dialog.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/cards/image_edit_dialog.dart';

class AppSettingsModal extends ConsumerStatefulWidget {
  final AppModel app;

  const AppSettingsModal({super.key, required this.app});

  @override
  ConsumerState<AppSettingsModal> createState() => _AppSettingsModalState();
}

class _AppSettingsModalState extends ConsumerState<AppSettingsModal> {
  late AppModel _currentApp;

  @override
  void initState() {
    super.initState();
    _currentApp = widget.app;
  }

  Future<void> _selectImage() async {
    final List<String> imageAssets = [
      'assets/images/palworld.jpg',
      'assets/images/dyinglight2.jpg',
      'assets/images/discord-logo.png',
      'assets/images/cyberpunk.webp',
      'assets/images/alyx_feature2.jpg',
      'assets/images/Unreal-Engine-Splash-Screen.jpg',
      'assets/images/Steam_icon_logo.png',
      'assets/images/IQ_-_Full_Body.webp',
      'assets/icons/images/discord-logo.png',
      'assets/icons/images/Visual_Studio_Code_1.35_icon.svg.png',
      'assets/icons/images/Steam_icon_logo.svg.png',
      'assets/icons/images/Google_Chrome_icon_(February_2022).svg.webp',
      'assets/icons/images/Calculator_512.webp',
    ];

    final String? selectedImagePath = await showDialog<String>(
      context: context,
      builder: (context) => ImageSelectionDialog(imagePaths: imageAssets),
    );

    if (selectedImagePath != null) {
      final ImageCropModel? newCrop = await showDialog<ImageCropModel>(
        context: context,
        builder: (context) => ImageEditDialog(
          imagePath: selectedImagePath,
          initialCrop: _currentApp.imagePath == selectedImagePath
              ? _currentApp.imageCrop
              : null,
        ),
      );

      if (newCrop != null) {
        setState(() {
          _currentApp = _currentApp.copyWith(
            imagePath: selectedImagePath,
            imageCrop: newCrop,
          );
        });
        ref.read(appDataRepositoryProvider.notifier).updateApp(_currentApp);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('App Settings for ${_currentApp.title}'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('ID: ${_currentApp.id}'),
            Text('Subtitle: ${_currentApp.subtitle}'),
            Text('Image Path: ${_currentApp.imagePath ?? 'N/A'}'),
            ElevatedButton(
              onPressed: _selectImage,
              child: const Text('Change Image'),
            ),
            Text('Executable Path: ${_currentApp.executablePath ?? 'N/A'}'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop(_currentApp);
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:custom_launcher/features/launcher/data/models/app_model.dart';

class ImageEditDialog extends StatefulWidget {
  final String imagePath;
  final ImageCropModel? initialCrop;

  const ImageEditDialog({super.key, required this.imagePath, this.initialCrop});

  @override
  State<ImageEditDialog> createState() => _ImageEditDialogState();
}

class _ImageEditDialogState extends State<ImageEditDialog> {
  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    if (widget.initialCrop != null && widget.initialCrop!.matrixData != null) {
      _transformationController.value = Matrix4.fromList(widget.initialCrop!.matrixData!);
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Image'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6, // Adjust width as needed
        height: MediaQuery.of(context).size.height * 0.6, // Adjust height as needed
        child: InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: const EdgeInsets.all(20.0),
          minScale: 0.1,
          maxScale: 4.0,
          constrained: false,
          clipBehavior: Clip.none,
          child: Image.asset(
            widget.imagePath,
            fit: BoxFit.none,
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            final matrixData = _transformationController.value.storage.toList();
            final newCrop = ImageCropModel(matrixData: matrixData);
            Navigator.of(context).pop(newCrop);
          },
        ),
      ],
    );
  }
}

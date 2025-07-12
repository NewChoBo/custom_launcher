import 'package:flutter/material.dart';
import 'package:custom_launcher/features/launcher/data/models/app_model.dart';

class CroppedImage extends StatelessWidget {
  final AppModel app;

  const CroppedImage({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    if (app.imagePath == null) {
      return const SizedBox.shrink();
    }

    final Image imageWidget = Image.asset(
      app.imagePath!,
      fit: BoxFit.none,
    );

    if (app.imageCrop == null || app.imageCrop!.matrixData == null) {
      return imageWidget;
    }

    final Matrix4 matrix = Matrix4.fromList(app.imageCrop!.matrixData!);

    return ClipRect(
      child: Transform(
        transform: matrix,
        alignment: FractionalOffset.topLeft,
        child: imageWidget,
      ),
    );
  }
}

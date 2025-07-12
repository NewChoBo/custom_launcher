import 'package:flutter/material.dart';

class ImageSelectionDialog extends StatefulWidget {
  final List<String> imagePaths;

  const ImageSelectionDialog({super.key, required this.imagePaths});

  @override
  State<ImageSelectionDialog> createState() => _ImageSelectionDialogState();
}

class _ImageSelectionDialogState extends State<ImageSelectionDialog> {
  String? _selectedImagePath;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select an Image'),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: widget.imagePaths.length,
          itemBuilder: (context, index) {
            final imagePath = widget.imagePaths[index];
            final isSelected = _selectedImagePath == imagePath;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedImagePath = imagePath;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.blueAccent : Colors.transparent,
                    width: 3.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
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
          child: const Text('Select'),
          onPressed: () {
            Navigator.of(context).pop(_selectedImagePath);
          },
        ),
      ],
    );
  }
}

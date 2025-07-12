import 'dart:io';

import 'package:collection/collection.dart';
import 'package:custom_launcher/core/providers/app_providers.dart';
import 'package:custom_launcher/features/launcher/data/models/app_model.dart';
import 'package:custom_launcher/features/launcher/presentation/providers/launcher_providers.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/shared/cropped_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomCard extends ConsumerStatefulWidget {
  const CustomCard({super.key, required this.appId});

  final String appId;

  @override
  ConsumerState<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends ConsumerState<CustomCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appDataRepositoryAsyncValue = ref.watch(appDataRepositoryProvider);
    final editingAppId = ref.watch(editingAppIdProvider);
    final isEditing = editingAppId == widget.appId;

    // Get TransformationController from provider
    final transformationController = ref.watch(
      editingTransformationControllerProvider,
    );

    return appDataRepositoryAsyncValue.when(
      data: (apps) {
        final AppModel? app = apps.firstWhereOrNull(
          (app) => app.id == widget.appId,
        );

        if (app == null) {
          return const SizedBox.shrink();
        }

        // Initialize transformation controller if entering edit mode
        if (isEditing && transformationController == null) {
          final newController = TransformationController();
          if (app.imageCrop != null && app.imageCrop!.matrixData != null) {
            newController.value = Matrix4.fromList(app.imageCrop!.matrixData!);
          }
          ref.read(editingTransformationControllerProvider.notifier).state =
              newController;
        } else if (!isEditing && transformationController != null) {
          // Exit edit mode, dispose controller
          transformationController.dispose();
          ref.read(editingTransformationControllerProvider.notifier).state =
              null;
        }

        return GestureDetector(
          onSecondaryTapUp: (details) {
            if (!isEditing) {
              // Enter edit mode
              ref.read(editingAppIdProvider.notifier).state = widget.appId;
            }
            // If already editing, right-click does nothing, as Save/Cancel buttons are visible.
          },
          child: InkWell(
            onTap: isEditing
                ? null // Disable tap when editing
                : () => _launchApplication(
                    app.executablePath,
                    app.arguments,
                    app.title,
                  ),
            splashColor: Colors.white24,
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              color: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image or InteractiveViewer
                  if (isEditing &&
                      app.imagePath != null &&
                      transformationController != null)
                    InteractiveViewer(
                      transformationController: transformationController,
                      boundaryMargin: const EdgeInsets.all(20.0),
                      minScale: 0.1,
                      maxScale: 4.0,
                      constrained: false, // Allow unconstrained movement
                      clipBehavior:
                          Clip.none, // Allow content to draw outside bounds
                      child: Image.asset(
                        app.imagePath!,
                        fit: BoxFit.none,
                      ), // Use BoxFit.none for direct control
                    )
                  else
                    CroppedImage(app: app),

                  // Overlay content (text and buttons)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF1F2123,
                      ).withAlpha((255 * 0.5).round()),
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                app.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: <Widget>[
                                  Text(
                                    app.subtitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                ],
                              ),
                            ],
                          ),
                          if (isEditing) // Show buttons only in edit mode
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Save changes
                                    final matrixData = transformationController!
                                        .value
                                        .storage
                                        .toList();
                                    final updatedApp = app.copyWith(
                                      imageCrop: ImageCropModel(
                                        matrixData: matrixData,
                                      ),
                                    );
                                    ref
                                        .read(
                                          appDataRepositoryProvider.notifier,
                                        )
                                        .updateApp(updatedApp);
                                    ref
                                            .read(editingAppIdProvider.notifier)
                                            .state =
                                        null; // Exit edit mode
                                    // transformationController is disposed by the provider's onDispose
                                  },
                                  child: const Text('Save'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    // Cancel changes
                                    ref
                                            .read(editingAppIdProvider.notifier)
                                            .state =
                                        null; // Exit edit mode
                                    // transformationController is disposed by the provider's onDispose
                                  },
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Future<void> _launchApplication(
    String? executablePath,
    List<String>? arguments,
    String title,
  ) async {
    if (executablePath == null || executablePath.isEmpty) {
      debugPrint('No executable path provided for $title');
      return;
    }

    try {
      debugPrint('Launching: $executablePath with args: $arguments');

      await Process.start(
        executablePath,
        arguments ?? [],
        mode: ProcessStartMode.detached,
      );

      debugPrint('Successfully launched: $title');
    } catch (e) {
      debugPrint('Failed to launch $title: $e');
    }
  }
}

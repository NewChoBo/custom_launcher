import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final editingAppIdProvider = StateProvider<String?>((ref) => null);

final editingTransformationControllerProvider = StateProvider<TransformationController?>((ref) {
  return null;
});
import 'dart:async';

import 'package:flutter/services.dart';

/// Dart side of [com.newaura.bookish/native_image].
///
/// Native opens gallery/camera; picked file paths arrive on [images].
class NativeImagePicker {
  NativeImagePicker._() {
    _channel.setMethodCallHandler(_onMethodCall);
  }

  static final NativeImagePicker instance = NativeImagePicker._();

  static const MethodChannel _channel =
      MethodChannel('com.newaura.bookish/native_image');

  final StreamController<String> _imagesController =
      StreamController<String>.broadcast();

  Stream<String> get images => _imagesController.stream;

  Future<void> openGallery() {
    return _channel.invokeMethod<void>('openGallery');
  }

  Future<void> openCamera() {
    return _channel.invokeMethod<void>('openCamera');
  }

  Future<void> _onMethodCall(MethodCall call) async {
    if (call.method != 'onImagePicked') {
      return;
    }
    final Object? arguments = call.arguments;
    if (arguments is! Map) {
      return;
    }
    final Object? path = arguments['path'];
    if (path is! String || path.isEmpty) {
      return;
    }
    _imagesController.add(path);
  }
}

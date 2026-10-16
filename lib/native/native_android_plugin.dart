import 'dart:async';
import 'dart:io';

import 'package:bookish/native/hybrid_composition_view.dart';
import 'package:bookish/native/native_image_picker.dart';
import 'package:flutter/material.dart';

class NativeAndroidPlugin extends StatefulWidget {
  static String routeName = '/native-android-plugin';

  const NativeAndroidPlugin({super.key});

  @override
  State<NativeAndroidPlugin> createState() => _NativeAndroidPluginState();
}

class _NativeAndroidPluginState extends State<NativeAndroidPlugin> {
  String? _imagePath;
  StreamSubscription<String>? _imageSubscription;

  @override
  void initState() {
    super.initState();
    _imageSubscription = NativeImagePicker.instance.images.listen((path) {
      if (!mounted) {
        return;
      }
      setState(() {
        _imagePath = path;
      });
    });
  }

  @override
  void dispose() {
    _imageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Native Android Plugin')),
      body: Column(
        children: [
          const Expanded(
            flex: 2,
            child: HybridCompositionView(
              viewType: HybridCompositionView.composeViewType,
            ),
          ),
          Expanded(
            flex: 3,
            child: _imagePath == null
                ? const Center(
                    child: Text('Pick an image from the native buttons above'),
                  )
                : Image.file(File(_imagePath!), fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

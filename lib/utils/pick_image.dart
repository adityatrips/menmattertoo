import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class MyImagePicker extends StatefulWidget {
  final void Function(Uint8List?) setFile;

  const MyImagePicker({
    super.key,
    required this.setFile,
  });

  @override
  State<MyImagePicker> createState() => _MyImagePickerState();
}

class _MyImagePickerState extends State<MyImagePicker> {
  final ImagePicker picker = ImagePicker();
  Uint8List? croppedFile;

  Future<void> _pickImage() async {
    XFile? im = await picker.pickImage(source: ImageSource.gallery);
    Uint8List? croppedFile = await _getCropped(im?.path);

    if (croppedFile == null) {
      widget.setFile(null);
    } else {
      widget.setFile(croppedFile);
      Navigator.pop(context);
    }
    return;
  }

  Future<Uint8List?> _getCropped(String? imPath) async {
    try {
      CroppedFile? file = await ImageCropper().cropImage(
        sourcePath: imPath ?? '',
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.grey.shade900,
            toolbarWidgetColor: Colors.white,
            hideBottomControls: true,
            lockAspectRatio: true,
            initAspectRatio: CropAspectRatioPreset.square,
          ),
        ],
      );

      return file!.readAsBytes().then((val) => val);
    } catch (e) {
      Navigator.pop(context);
    }
    return null;
  }

  @override
  void initState() {
    if (mounted) {
      _pickImage();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

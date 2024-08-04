import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:men_matter_too/utils/show_snackbar.dart';

class MyImagePicker extends StatefulWidget {
  final BuildContext buildContext;

  const MyImagePicker({
    super.key,
    required this.buildContext,
  });

  @override
  State<MyImagePicker> createState() => _MyImagePickerState();
}

class _MyImagePickerState extends State<MyImagePicker> {
  final ImagePicker picker = ImagePicker();
  XFile? image;
  CroppedFile? croppedFile;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        throw Exception('File is null');
      }

      setState(() {
        this.image = image;
      });
      await _getCropped();
    } catch (e) {
      log("message: Can't crop because image is not selected");
      showSnackbar(
        widget.buildContext,
        "Can't crop because image is not selected",
        type: TypeOfSnackbar.error,
      );
    } finally {
      log("popping");
      Navigator.pop(widget.buildContext);
      // Navigator.push(
      //   widget.buildContext,
      //   MaterialPageRoute(
      //     builder: (context) => const EditProfile(),
      //   ),
      // );
    }
  }

  Future<CroppedFile> _getCropped() async {
    CroppedFile? file = await ImageCropper().cropImage(
      sourcePath: image!.path,
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

    if (file == null) {
      throw Exception('File is null');
    }
    Navigator.pop(widget.buildContext, file);
    return file;
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

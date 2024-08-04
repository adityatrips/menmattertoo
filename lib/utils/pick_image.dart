import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class MyImagePicker extends StatefulWidget {
  const MyImagePicker({
    super.key,
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

      if (image == null) return;

      setState(() {
        this.image = image;
      });
      await _getCropped();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image cropping failed, as image is null.'),
        ),
      );
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
    Navigator.pop(context, file);
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

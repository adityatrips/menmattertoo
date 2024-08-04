import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:men_matter_too/utils/show_snackbar.dart';

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

      if (image == null) {
        throw Exception('File is null');
      }

      setState(() {
        this.image = image;
      });
      await _getCropped();
    } catch (e) {
      Navigator.pop(context);
      showSnackbar(context, "Can't crop because image is not selected",
          type: TypeOfSnackbar.error);
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

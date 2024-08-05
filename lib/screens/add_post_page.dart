import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:men_matter_too/resources/auth_methods.dart';
import 'package:men_matter_too/utils/create_animated_route.dart';
import 'package:men_matter_too/utils/pick_image.dart';
import 'package:men_matter_too/utils/show_snackbar.dart';
import 'package:men_matter_too/widgets/app_bar.dart';
import 'package:men_matter_too/widgets/custom_button.dart';
import 'package:men_matter_too/widgets/text_field_input.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  AddPostPageState createState() => AddPostPageState();
}

class AddPostPageState extends State<AddPostPage> {
  final title = TextEditingController();
  final caption = TextEditingController();

  final _auth = FirebaseAuth.instance;

  Uint8List? file;

  void setFile(Uint8List? file) {
    setState(() {
      this.file = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            children: [
              file == null
                  ? Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: const Center(
                          child: Text(
                            "Click on \"Add a picture\"",
                            style: TextStyle(
                              fontFamily: "BN",
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Image.memory(file!),
              const SizedBox(height: 10),
              CustomButton(
                buttonText: "Add a picture",
                onTap: () async {
                  Navigator.push(
                    context,
                    AnimatedRoute(
                      context: context,
                      page: MyImagePicker(
                        setFile: setFile,
                      ),
                    ).createRoute(),
                  );
                },
              ),
              const SizedBox(height: 10),
              TextFieldInput(controller: title, hintText: "Title"),
              const SizedBox(height: 10),
              TextFieldInput(
                controller: caption,
                hintText: 'Bio',
                textInputType: TextInputType.multiline,
                maxLength: 250,
                multiline: true,
                autoCapitalize: TextCapitalization.sentences,
              ),
              const SizedBox(height: 10),
              CustomButton(
                buttonText: "Add post",
                onTap: () async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      });
                  final res = await AuthMethods().uploadPost(
                    title: title.text,
                    caption: caption.text,
                    file: file!,
                  );
                  if (res == 'success') {
                    showSnackbar(context, "Post added successfully",
                        type: TypeOfSnackbar.success);
                  } else {
                    showSnackbar(context, res, type: TypeOfSnackbar.error);
                  }
                  Navigator.pop(context);
                  Navigator.pop(context);
                  title.clear();
                  caption.clear();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:men_matter_too/providers/user_provider.dart';
import 'package:men_matter_too/utils/create_animated_route.dart';
import 'package:men_matter_too/utils/loading_indicator.dart';
import 'package:men_matter_too/utils/pick_image.dart';
import 'package:men_matter_too/widgets/app_bar.dart';
import 'package:men_matter_too/widgets/custom_button.dart';
import 'package:men_matter_too/widgets/text_field_input.dart';
import 'package:provider/provider.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  AddPostPageState createState() => AddPostPageState();
}

class AddPostPageState extends State<AddPostPage> {
  final title = TextEditingController();
  final caption = TextEditingController();

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
        padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(
          top: 20,
        ),
        child: Center(
          child: Consumer<UserProvider>(
            builder: (context, user, _) {
              return ListView(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                children: buildAddPost(context, user),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> buildAddPost(BuildContext context, UserProvider user) {
    return [
      if (file == null)
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Click on "Add a picture"',
                  style: TextStyle(
                    fontFamily: "BN",
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        )
      else
        Image.memory(file!),
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
        hintText: 'Caption',
        textInputType: TextInputType.multiline,
        maxLength: 1000,
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
              return const LoadingIndicator();
            },
          );
          await user.uploadAndAddPost(
            title: title.text,
            caption: caption.text,
            file: file!,
          );
          Navigator.pop(context);
          Navigator.pop(context);
          title.clear();
          caption.clear();
        },
      ),
    ];
  }
}

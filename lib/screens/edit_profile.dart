import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:men_matter_too/providers/user_provider.dart';
import 'package:men_matter_too/utils/create_animated_route.dart';
import 'package:men_matter_too/utils/loading_indicator.dart';
import 'package:men_matter_too/utils/pick_image.dart';
import 'package:men_matter_too/widgets/app_bar.dart';
import 'package:men_matter_too/widgets/custom_button.dart';
import 'package:men_matter_too/widgets/text_field_input.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  EditProfileState createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  final bioController = TextEditingController();
  final nameController = TextEditingController();
  final usernameController = TextEditingController();

  Uint8List? file;

  void setFile(Uint8List? file) {
    setState(() {
      this.file = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, user, _) {
        bioController.text = user.loggedUser!.bio.replaceAll("\\n", "\n");
        nameController.text = user.loggedUser!.name;
        usernameController.text = user.loggedUser!.username;

        return Scaffold(
          appBar: myAppBar(context),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: file == null
                          ? CachedNetworkImage(
                              imageUrl: user.loggedUser!.profilePicture,
                              placeholder: (context, url) =>
                                  const LoadingIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error_rounded),
                              useOldImageOnUrlChange: true,
                            )
                          : Image.memory(file!),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
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
                    buttonText: "Edit profile picture",
                  ),
                  const SizedBox(height: 20),
                  TextFieldInput(
                    controller: nameController,
                    hintText: 'Name',
                    autoCapitalize: TextCapitalization.words,
                  ),
                  const SizedBox(height: 20),
                  TextFieldInput(
                    controller: usernameController,
                    hintText: 'Username',
                  ),
                  const SizedBox(height: 20),
                  TextFieldInput(
                    controller: bioController,
                    hintText: 'Bio',
                    textInputType: TextInputType.multiline,
                    maxLength: 250,
                    multiline: true,
                    autoCapitalize: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const Center(
                            child: LoadingIndicator(),
                          );
                        },
                      );
                      await user.updateProfile(
                        bio: bioController.text,
                        name: nameController.text,
                        username: usernameController.text,
                        file: file,
                      );
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    buttonText: "Save",
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

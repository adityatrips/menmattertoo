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

class EditPostPage extends StatefulWidget {
  final String uid;
  final String title;
  final String caption;
  final String file;

  const EditPostPage({
    super.key,
    required this.uid,
    required this.title,
    required this.caption,
    required this.file,
  });

  @override
  EditPostPageState createState() => EditPostPageState();
}

class EditPostPageState extends State<EditPostPage> {
  final _title = TextEditingController();
  final _caption = TextEditingController();
  Uint8List? _file;

  @override
  void initState() {
    _title.text = widget.title;
    _caption.text = widget.caption;
    super.initState();
  }

  void setFile(Uint8List? file) {
    setState(() {
      _file = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
      if (widget.file.isNotEmpty)
        CachedNetworkImage(
          imageUrl: widget.file,
        )
      else if (_file == null || widget.file.isEmpty)
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
        Image.memory(_file!),
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
      TextFieldInput(controller: _title, hintText: "Title"),
      const SizedBox(height: 10),
      TextFieldInput(
        controller: _caption,
        hintText: 'Caption',
        textInputType: TextInputType.multiline,
        maxLength: 1000,
        multiline: true,
        autoCapitalize: TextCapitalization.sentences,
      ),
      const SizedBox(height: 10),
      CustomButton(
        buttonText: "Edit post",
        onTap: () async {
          showDialog(
            context: context,
            builder: (context) {
              return const LoadingIndicator();
            },
          );
          await user.editPost(
            uid: widget.uid,
            title: _title.text,
            caption: _caption.text,
            file: _file,
            url: widget.file,
          );
          Navigator.pop(context);
          Navigator.pop(context);
          _title.clear();
          _caption.clear();
        },
      ),
    ];
  }
}

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:men_matter_too/models/models.dart';
import 'package:men_matter_too/providers/user_provider.dart';
import 'package:men_matter_too/utils/show_snackbar.dart';
import 'package:men_matter_too/widgets/app_bar.dart';
import 'package:provider/provider.dart';

class OnePostPage extends StatefulWidget {
  final Post post;

  const OnePostPage({
    super.key,
    required this.post,
  });

  @override
  OnePostPageState createState() => OnePostPageState();
}

class OnePostPageState extends State<OnePostPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context),
      body: Consumer<UserProvider>(
        builder: (context, user, _) {
          if (user.postFoundById == null) {
            user.getPostByUid(widget.post.postUid);
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          Post post = user.postFoundById!;
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  CachedNetworkImage(
                    imageUrl: post.img,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          post.likes.toList().map((e) {
                            return e.id;
                          }).contains(user.loggedUser!.uid)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          user.likeOrUnlikeAPost(
                            post.postUid,
                            user.loggedUser!.uid,
                          );
                          user.getPostByUid(widget.post.postUid);
                        },
                      ),
                      Text("${post.likes.length}"),
                      const SizedBox(width: 10),
                      Text("${post.comments.length}"),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.save_alt_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          var link = post.img;

                          final response = await http.get(Uri.parse(link));
                          final bytes = response.bodyBytes;

                          const directory =
                              "/storage/emulated/0/DCIM/MenMatterToo";

                          if (Directory(
                                directory,
                              ).existsSync() ==
                              false) {
                            Directory(
                              directory,
                            ).createSync(
                              recursive: true,
                            );
                          }

                          final path =
                              '$directory/${post.postUid.toString().replaceAll(" ", "_")}-${DateTime.now().millisecondsSinceEpoch}.png';

                          log(path);
                          await File(path).writeAsBytes(bytes);

                          showSnackbar(
                            "Image saved to /storage/emulated/0/DCIM/MenMatterToo",
                            type: TypeOfSnackbar.success,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      post.title,
                      style: const TextStyle(
                        fontFamily: "BN",
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(post.caption),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

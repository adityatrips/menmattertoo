import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:men_matter_too/models/models.dart';
import 'package:men_matter_too/providers/user_provider.dart';
import 'package:men_matter_too/screens/edit_post_page.dart';
import 'package:men_matter_too/utils/create_animated_route.dart';
import 'package:men_matter_too/utils/show_snackbar.dart';
import 'package:men_matter_too/widgets/app_bar.dart';
import 'package:provider/provider.dart';

class OnePostPage extends StatefulWidget {
  final String post;

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
          if (user.postFoundById == null ||
              user.postFoundById!.postUid != widget.post) {
            user.getPostByUid(widget.post);
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
                          user.getPostByUid(widget.post);
                        },
                      ),
                      Text("${post.likes.length}"),
                      const Spacer(),
                      user.loggedUser!.uid == post.author.id
                          ? IconButton(
                              icon: const Icon(
                                Icons.mode_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  AnimatedRoute(
                                    context: context,
                                    page: EditPostPage(
                                      uid: post.postUid,
                                      title: post.title,
                                      caption: post.caption,
                                      file: post.img,
                                    ),
                                  ).createRoute(),
                                );
                              },
                            )
                          : const SizedBox(),
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
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontFamily: "BN",
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder(
                    future: post.author.get(),
                    builder: (builder, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(snapshot.error.toString()),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Text("Author not found");
                      }

                      return Text(
                        "${snapshot.data!['name']} wrote this.",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      );
                    },
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

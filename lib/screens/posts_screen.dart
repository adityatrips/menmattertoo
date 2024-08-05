import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:men_matter_too/models/models.dart';
import 'package:men_matter_too/resources/auth_methods.dart';
import 'package:men_matter_too/screens/profile_page.dart';
import 'package:men_matter_too/utils/create_animated_route.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  PostsScreenState createState() => PostsScreenState();
}

class PostsScreenState extends State<PostsScreen> {
  final _firestore = FirebaseFirestore.instance;

  Future<List<Post>> getPosts() async {
    final posts = await _firestore.collection("posts").get();
    List<Post> postsList = [];

    for (var post in posts.docs) {
      postsList.add(Post.fromSnapshot(post));
    }

    log(postsList.toString());

    return postsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              FutureBuilder(
                future: getPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return const Text("An error occurred");
                  }

                  List<Post> post = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: post.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          _postsCard(post[index]),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _postsCard(Post post) {
    return FutureBuilder(
      future: AuthMethods().getUserDetailsF(post.author),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Text("An error occurred");
        }

        if (snapshot.data == null) {
          return const Text("An error occurred");
        }

        MyUser user = MyUser.fromSnapshot(snapshot.data!);
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              AnimatedRoute(
                context: context,
                page: ProfilePage(
                  user: user,
                ),
              ).createRoute(),
            );
          },
          child: Card(
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      user.profilePicture,
                    ),
                  ),
                  title: Text(user.name),
                  subtitle: Text("@${user.username}"),
                ),
                Image.network(post.img),
                ListTile(
                  title: Text(
                    post.title,
                    style: const TextStyle(
                      fontFamily: "BN",
                      fontSize: 20,
                    ),
                  ),
                  subtitle: Text(post.caption),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

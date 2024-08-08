import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:men_matter_too/models/models.dart';
import 'package:men_matter_too/providers/user_provider.dart';
import 'package:men_matter_too/screens/one_post_page.dart';
import 'package:men_matter_too/screens/profile_page.dart';
import 'package:men_matter_too/utils/create_animated_route.dart';
import 'package:men_matter_too/utils/loading_indicator.dart';
import 'package:men_matter_too/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class PostAuthor {
  final Post posts;
  final MyUser user;

  PostAuthor({
    required this.posts,
    required this.user,
  });
}

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  PostsScreenState createState() => PostsScreenState();
}

class PostsScreenState extends State<PostsScreen> {
  @override
  void initState() {
    Provider.of<UserProvider>(
      context,
      listen: false,
    ).getAllUsers();

    Provider.of<UserProvider>(
      context,
      listen: false,
    ).getLoggedInUser();

    Provider.of<UserProvider>(
      context,
      listen: false,
    ).getAllPosts();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Provider.of<UserProvider>(
        context,
        listen: false,
      ).getAllPosts(),
      child: Consumer<UserProvider>(
        builder: (context, user, _) {
          if (user.posts == null) {
            user.getAllPosts();
            return const LoadingIndicator();
          } else if (user.posts!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Oops! No one has posted yet.",
                    style: TextStyle(
                      fontFamily: "BN",
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  CustomButton(
                    buttonText: "Refresh",
                    onTap: () => user.getAllPosts(),
                  ),
                ],
              ),
            );
          } else {
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: user.posts!.length,
                  itemBuilder: (context, index) {
                    return _postsCard(user.posts![index]);
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _postsCard(Post post) {
    return Consumer<UserProvider>(builder: (context, providedUser, _) {
      MyUser user = providedUser.allUsers!.firstWhere(
        (element) => element.uid == post.author.id,
      );

      return Card(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  AnimatedRoute(
                    context: context,
                    page: ProfilePage(
                      user: user,
                    ),
                  ).createRoute(),
                );
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    user.profilePicture,
                  ),
                ),
                title: Text(user.name),
                subtitle: Text("@${user.username}"),
              ),
            ),
            GestureDetector(
              onTap: () async {
                await providedUser.getPostByUid(post.postUid);
                Navigator.push(
                  context,
                  AnimatedRoute(
                    context: context,
                    page: OnePostPage(post: post.postUid),
                  ).createRoute(),
                );
              },
              child: CachedNetworkImage(
                imageUrl: post.img,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  AnimatedRoute(
                    context: context,
                    page: OnePostPage(post: post.postUid),
                  ).createRoute(),
                );
              },
              child: ListTile(
                title: Text(
                  post.title,
                  style: const TextStyle(
                    fontFamily: "BN",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.caption.length >= 20
                          ? post.caption.substring(0, 20)
                          : post.caption,
                    ),
                    Text(
                      "Read more...",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:men_matter_too/models/models.dart';
import 'package:men_matter_too/providers/user_provider.dart';
import 'package:men_matter_too/screens/edit_profile.dart';
import 'package:men_matter_too/screens/followers_page.dart';
import 'package:men_matter_too/screens/following_page.dart';
import 'package:men_matter_too/screens/one_post_page.dart';
import 'package:men_matter_too/utils/create_animated_route.dart';
import 'package:men_matter_too/utils/loading_indicator.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final MyUser? user;

  const ProfilePage({
    super.key,
    this.user,
  });

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  bool isUser = false;
  CroppedFile? file;

  void setFile(CroppedFile file) {
    setState(() {
      this.file = file;
    });
  }

  Widget _userProfilePage() {
    return Consumer<UserProvider>(
      builder: (context, user, _) {
        if (user.loggedUser == null) {
          user.getLoggedInUser();
          return const LoadingIndicator();
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              user.getLoggedInUser();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  buildProfilePicture(context, user.loggedUser!),
                  const SizedBox(height: 20),
                  buildUserStats(user.loggedUser!),
                  const SizedBox(height: 10),
                  Divider(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 10),
                  buildUserDetails(user.loggedUser!),
                  const SizedBox(height: 10),
                  Divider(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 10),
                  buildUserPosts(user.loggedUser!),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _otherProfilePage(MyUser myUser) {
    Provider.of<UserProvider>(context, listen: false).getUserByUid(myUser.uid);

    return Consumer<UserProvider>(
      builder: (context, user, _) {
        if (user.userFoundByUid == null ||
            user.userFoundByUid!.uid != myUser.uid) {
          user.getUserByUid(myUser.uid);
          return const LoadingIndicator();
        }

        return Scaffold(
          floatingActionButton: FloatingActionButton.small(
            onPressed: () async {
              await user.followOrUnfollowUser(
                  user.loggedUser!.uid, user.userFoundByUid!.uid);
              await user.getUserByUid(myUser.uid);
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            child: Icon(
              user.userFoundByUid!.followers.toList().map((e) {
                return e.id;
              }).contains(user.loggedUser!.uid)
                  ? Icons.person_remove_alt_1_rounded
                  : Icons.person_add_alt_1_rounded,
              color: Colors.white,
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              user.getLoggedInUser();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  buildProfilePicture(context, user.userFoundByUid!),
                  const SizedBox(height: 20),
                  buildUserStats(user.userFoundByUid!),
                  const SizedBox(height: 10),
                  Divider(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 10),
                  buildUserDetails(user.userFoundByUid!),
                  const SizedBox(height: 10),
                  Divider(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 10),
                  buildUserPosts(user.userFoundByUid!),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ListView buildUserPosts(MyUser user) {
    if (user.posts.isEmpty) {
      return ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          Center(
            child: Text(
              "${user.name}\nYou haven't made any posts yet.\nAdd by holding the profile picture below!",
              style: const TextStyle(
                fontFamily: "BN",
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: user.posts.length,
      itemBuilder: (buiilder, index) {
        return FutureBuilder(
          future: user.posts[index].get(),
          builder: (context, future) {
            if (future.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator();
            }

            if (future.hasError) {
              return const Center(
                child: Text("An error occurred."),
              );
            }

            if (future.data == null || !future.hasData) {
              return const Center(
                child: Text("No data found."),
              );
            }

            Post post = Post.fromSnapshot(future.data!);
            return postCard(context, post);
          },
        );
      },
    );
  }

  GestureDetector postCard(BuildContext context, Post post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OnePostPage(post: post),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 100,
          ),
          color: Theme.of(context).colorScheme.tertiary,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: CachedNetworkImage(imageUrl: post.img),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Text(
                  post.title,
                  style: const TextStyle(
                    fontFamily: "BN",
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column buildUserDetails(MyUser user) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.name.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 30,
            fontFamily: "BN",
          ),
        ),
        Text(
          "@${user.username}",
          style: const TextStyle(
            fontWeight: FontWeight.w200,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          user.bio,
        )
      ],
    );
  }

  Row buildUserStats(MyUser user) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: Center(
              child: Text(
                "${user.posts.length}\nPosts",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                AnimatedRoute(
                  context: context,
                  page: FollowingPage(
                    user: isUser ? null : user,
                  ),
                ).createRoute(),
              );
            },
            child: SizedBox(
              height: 50,
              child: Center(
                child: Text(
                  "${user.following.length}\nFollowing",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                AnimatedRoute(
                  context: context,
                  page: FollowersPage(
                    user: isUser ? null : user,
                  ),
                ).createRoute(),
              );
            },
            child: SizedBox(
              height: 50,
              child: Center(
                child: Text(
                  "${user.followers.length}\nFollowers",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Stack buildProfilePicture(BuildContext context, MyUser user) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: CachedNetworkImage(
            width: (MediaQuery.sizeOf(context).width - 40) * .5,
            height: (MediaQuery.sizeOf(context).width - 40) * .5,
            imageUrl: user.profilePicture,
          ),
        ),
        isUser
            ? Positioned(
                bottom: 0,
                right: (MediaQuery.sizeOf(context).width - 40) * .25,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(15).copyWith(
                      topRight: const Radius.circular(0),
                      bottomLeft: const Radius.circular(0),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        AnimatedRoute(
                          context: context,
                          page: const EditProfile(),
                        ).createRoute(),
                      );
                    },
                  ),
                ),
              )
            : const SizedBox.shrink()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      isUser = true;
    }

    if (isUser) {
      return _userProfilePage();
    }

    return _otherProfilePage(
      widget.user!,
    );
  }
}

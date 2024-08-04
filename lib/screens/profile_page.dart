import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:men_matter_too/models/models.dart';
import 'package:men_matter_too/resources/auth_methods.dart';
import 'package:men_matter_too/widgets/custom_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: FutureBuilder(
          future: AuthMethods().getUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            if (!snapshot.hasData) {
              return const Center(
                child: Text("No data found"),
              );
            }

            return ListView(
              children: [
                const SizedBox(height: 20),
                _buildUserHeader(context, snapshot.data!),
                const SizedBox(height: 10),
                _userInformation(context, snapshot.data!),
                const SizedBox(height: 10),
                _userProfileInteraction(context, snapshot.data!),
                const SizedBox(height: 10),
                _userPosts(context, snapshot.data!),
              ],
            );
          },
        ),
      ),
    );
  }

  // * User profile interaction starts here
  Widget _userProfileInteraction(BuildContext context, MyUser) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            fontSize: 16,
            fontFamily: "DM",
            buttonText: "Edit Profile",
            height: 35,
            borderRadius: 5,
            backgroundColor: Theme.of(context).colorScheme.primary,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomButton(
            fontSize: 16,
            fontFamily: "DM",
            buttonText: "Share Profile",
            height: 35,
            borderRadius: 5,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            onTap: () {},
          ),
        ),
      ],
    );
  }
  // * User profile interaction starts here

  // * User posts starts here

  Widget _userPosts(BuildContext context, MyUser user) {
    if (user.posts.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height / 7,
          ),
          Icon(
            Icons.camera_alt_rounded,
            color: Theme.of(context).colorScheme.onSurface,
            size: 80,
          ),
          Text(
            "Woah! It's empty here",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 30,
              fontFamily: "BN",
            ),
          ),
        ],
      );
    }
    return Container();
  }

  // * User posts starts here

  // * User information starts here

  Widget _userInformation(BuildContext context, MyUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          user.name,
          style: TextStyle(
            fontSize: 20,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          user.bio.replaceAll("\\n", "\n"),
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  // * User information ends here

  // * User header starts here
  Widget _buildUserHeader(BuildContext context, MyUser user) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: Column(
          children: [
            _profileHeader(user),
          ],
        ),
      ),
    );
  }

  Row _profileHeader(MyUser user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CachedNetworkImage(
                  imageUrl: user.profilePicture,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  useOldImageOnUrlChange: true,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              height: 40,
              width: 40,
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {},
                icon: const Icon(Icons.edit_rounded),
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        _profileStat(
          postsLength: user.posts.length,
          followingLength: user.following.length,
          followersLength: user.followers.length,
        ),
      ],
    );
  }

  Expanded _profileStat({
    required int postsLength,
    required int followingLength,
    required int followersLength,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _individualStat(postsLength, "Posts"),
          _individualStat(followingLength, "Following"),
          _individualStat(followersLength, "Followers"),
        ],
      ),
    );
  }

  SizedBox _individualStat(int statLength, String stat) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 160) / 3,
      child: Column(
        children: [
          Text(
            "$statLength",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18,
            ),
          ),
          Text(
            stat,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          )
        ],
      ),
    );
  }

  // * User header ends here
}

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:men_matter_too/models/models.dart';
import 'package:men_matter_too/resources/auth_methods.dart';
import 'package:men_matter_too/screens/edit_profile.dart';
import 'package:men_matter_too/screens/followers_page.dart';
import 'package:men_matter_too/screens/following_page.dart';
import 'package:men_matter_too/utils/create_animated_route.dart';
import 'package:men_matter_too/widgets/custom_button.dart';

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
  CroppedFile? file;

  void setFile(CroppedFile file) {
    setState(() {
      this.file = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isUser = widget.user == null;

    return Scaffold(
      appBar: isUser
          ? null
          : AppBar(
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: SvgPicture.asset(
                    "assets/logo_extended.svg",
                    width: 150,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
              title: Text(
                "@${widget.user!.username}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: isUser
              ? StreamBuilder(
                  stream: AuthMethods().getUserDetails(),
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
                        _buildUserHeader(
                          context,
                          MyUser.fromJson(snapshot.data!.data()!),
                        ),
                        const SizedBox(height: 10),
                        _userInformation(
                          context,
                          MyUser.fromJson(snapshot.data!.data()!),
                        ),
                        const SizedBox(height: 10),
                        _userProfileInteraction(
                          context,
                          MyUser.fromJson(snapshot.data!.data()!),
                          isUser: isUser,
                        ),
                        const SizedBox(height: 10),
                        _userPosts(
                          context,
                          MyUser.fromJson(snapshot.data!.data()!),
                        ),
                      ],
                    );
                  },
                )
              : StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(widget.user!.uid)
                      .snapshots(),
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
                        _buildUserHeader(
                          context,
                          MyUser.fromJson(snapshot.data!.data()!),
                        ),
                        const SizedBox(height: 10),
                        _userInformation(
                          context,
                          MyUser.fromJson(snapshot.data!.data()!),
                        ),
                        const SizedBox(height: 10),
                        _userProfileInteraction(
                          context,
                          MyUser.fromJson(snapshot.data!.data()!),
                          isUser: isUser,
                        ),
                        const SizedBox(height: 10),
                        _userPosts(
                          context,
                          MyUser.fromJson(snapshot.data!.data()!),
                        ),
                      ],
                    );
                  },
                )),
    );
  }

  // * User profile interaction starts here
  Widget _userProfileInteraction(
    BuildContext context,
    MyUser user, {
    bool isUser = false,
  }) {
    return Row(
      children: [
        if (isUser)
          Expanded(
            child: CustomButton(
              fontFamily: "DM",
              buttonText: "Edit Profile",
              height: 35,
              onTap: () {
                Navigator.of(context).push(
                  AnimatedRoute(
                    context: context,
                    page: const EditProfile(),
                  ).createRoute(),
                );
              },
            ),
          )
        else
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              if (!snapshot.hasData) {
                return const Text("No data found");
              }

              MyUser user = MyUser.fromJson(snapshot.data!.data()!);

              return Expanded(
                child: CustomButton(
                  onTap: () {
                    AuthMethods().followAndUnfollowUser(
                      selfUid: FirebaseAuth.instance.currentUser!.uid,
                      otherUid: user.uid,
                    );
                  },
                  buttonText: user.followers
                          .contains(FirebaseAuth.instance.currentUser!.uid)
                      ? "Unfollow"
                      : "Follow",
                ),
              );
            },
          ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomButton(
            fontFamily: "DM",
            buttonText: "Share Profile",
            height: 35,
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
          "@${user.username}",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
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
        CircleAvatar(
          radius: 50,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CachedNetworkImage(
              imageUrl: user.profilePicture,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              useOldImageOnUrlChange: true,
            ),
          ),
        ),
        const SizedBox(width: 20),
        _profileStat(
          user: user,
          postsLength: user.posts.length,
          followingLength: user.following.length,
          followersLength: user.followers.length,
        ),
      ],
    );
  }

  Expanded _profileStat({
    required MyUser user,
    required int postsLength,
    required int followingLength,
    required int followersLength,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _individualStat(postsLength, "Posts"),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                AnimatedRoute(
                  context: context,
                  page: FollowingPage(user: user),
                ).createRoute(),
              );
            },
            child: _individualStat(followingLength, "Following"),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                AnimatedRoute(
                  context: context,
                  page: FollowersPage(user: user),
                ).createRoute(),
              );
            },
            child: _individualStat(followersLength, "Followers"),
          ),
        ],
      ),
    );
  }

  SizedBox _individualStat(int statLength, String stat) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 160) / 3,
      height: (MediaQuery.of(context).size.width - 160) / 3,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
  }

  // * User header ends here
}

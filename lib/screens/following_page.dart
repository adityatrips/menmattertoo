import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:men_matter_too/models/models.dart';
import 'package:men_matter_too/screens/profile_page.dart';
import 'package:men_matter_too/utils/create_animated_route.dart';
import 'package:men_matter_too/widgets/app_bar.dart';

class FollowingPage extends StatefulWidget {
  final MyUser? user;

  const FollowingPage({super.key, required this.user});

  @override
  FollowingPageState createState() => FollowingPageState();
}

class FollowingPageState extends State<FollowingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _profileCard(user: widget.user!),
      ),
    );
  }

  Widget _profileCard({required MyUser user}) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.doc('users/${user.uid}').get(
            const GetOptions(source: Source.serverAndCache),
          ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text("An error occurred. Please try again later."),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: Text("No users found."),
          );
        }

        final following = MyUser.fromSnapshot(snapshot.data!).following;

        return ListView.separated(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(
            height: 10,
          ),
          itemCount: following.length,
          itemBuilder: (context, index) {
            String oneUser = following[index];

            return _oneUserCard(oneUser, user);
          },
        );
      },
    );
  }

  Widget _oneUserCard(String oneUser, MyUser user) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.doc("users/$oneUser").get(),
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

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: Text("No data could be found!"),
          );
        }

        final finalUser = MyUser.fromSnapshot(snapshot.data!);

        // return ClipRRect(
        //   borderRadius: BorderRadius.circular(20),
        //   child: BackdropFilter(
        //     filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        //     child: Container(
        //       width: 100,
        //       height: 50,
        //       decoration: BoxDecoration(
        //         color: Colors.blue.shade700.withAlpha(128),
        //         borderRadius: BorderRadius.circular(20),
        //       ),
        //     ),
        //   ),
        // );
        return ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: CachedNetworkImageProvider(
              finalUser.profilePicture,
            ),
          ),
          title: Text(
            finalUser.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            finalUser.username,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                AnimatedRoute(
                  context: context,
                  page: ProfilePage(
                    user: finalUser,
                  ),
                ).createRoute(),
              );
            },
            icon: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:men_matter_too/models/models.dart';
import 'package:men_matter_too/providers/user_provider.dart';
import 'package:men_matter_too/screens/profile_page.dart';
import 'package:men_matter_too/utils/create_animated_route.dart';
import 'package:men_matter_too/utils/loading_indicator.dart';
import 'package:men_matter_too/widgets/app_bar.dart';
import 'package:provider/provider.dart';

class FollowersPage extends StatefulWidget {
  final MyUser? user;

  const FollowersPage({super.key, required this.user});

  @override
  FollowersPageState createState() => FollowersPageState();
}

class FollowersPageState extends State<FollowersPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, user, _) {
        return Scaffold(
          appBar: myAppBar(context),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: _profileCard(user: widget.user ?? user.loggedUser!),
          ),
        );
      },
    );
  }

  Widget _profileCard({required MyUser user}) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(
        height: 10,
      ),
      itemCount: user.followers.length,
      itemBuilder: (context, index) {
        String oneUser = user.followers[index].id;

        return _oneUserCard(oneUser, user);
      },
    );
  }

  Widget _oneUserCard(String oneUser, MyUser user) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.doc("users/$oneUser").get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
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
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        );
      },
    );
  }
}

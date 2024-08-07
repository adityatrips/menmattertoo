import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:men_matter_too/models/models.dart';
import 'package:men_matter_too/providers/user_provider.dart';
import 'package:men_matter_too/screens/profile_page.dart';
import 'package:men_matter_too/utils/create_animated_route.dart';
import 'package:men_matter_too/utils/loading_indicator.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();
  MyUser? user;
  List<MyUser?> searchUserResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(builder: (context, user, _) {
        return RefreshIndicator(
          onRefresh: () async {
            await Provider.of<UserProvider>(context, listen: false)
                .getAllUsers();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(
              top: 20,
            ),
            child: _allProfiles(user),
          ),
        );
      }),
    );
  }

  Widget _allProfiles(UserProvider user) {
    if (user.allUsers == null) {
      user.getAllUsers();
      return const LoadingIndicator();
    }

    if (user.allUsers!.isEmpty) {
      return const Center(
        child: Text(
          "Yay! You're all caught up!",
          style: TextStyle(
            fontFamily: "BN",
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemCount: user.allUsers!.length,
      itemBuilder: (context, index) {
        return _profileCard(
          user: user.allUsers![index],
        );
      },
    );
  }

  Widget _profileCard({required MyUser user}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 100,
        ),
        color: Theme.of(context).colorScheme.tertiary,
        child: Row(
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: CachedNetworkImage(
                imageUrl: user.profilePicture,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontFamily: "BN",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "@${user.username}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: () {
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
            ),
          ],
        ),
      ),
    );
  }
}

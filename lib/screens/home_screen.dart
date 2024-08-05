import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:men_matter_too/providers/user_provider.dart';
import 'package:men_matter_too/resources/auth_methods.dart';
import 'package:men_matter_too/screens/add_post_page.dart';
import 'package:men_matter_too/screens/notification_screen.dart';
import 'package:men_matter_too/screens/posts_screen.dart';
import 'package:men_matter_too/screens/profile_page.dart';
import 'package:men_matter_too/screens/search_page.dart';
import 'package:men_matter_too/utils/create_animated_route.dart';
import 'package:men_matter_too/widgets/app_bar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, user, _) {
        return Scaffold(
          extendBody: true,
          appBar: myAppBar(context),
          body: IndexedStack(
            index: currentIndex,
            children: const [
              PostsScreen(),
              SearchPage(),
              NotificationScreen(),
              ProfilePage(),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            child: Row(
              children: [
                const SizedBox(width: 10),
                InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    setState(
                      () {
                        currentIndex = 0;
                      },
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.home,
                    ),
                  ),
                ),
                const Spacer(),
                InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    setState(
                      () {
                        currentIndex = 1;
                      },
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.search,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                const Spacer(),
                InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    setState(
                      () {
                        currentIndex = 2;
                      },
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.notifications,
                    ),
                  ),
                ),
                const Spacer(),
                InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    setState(
                      () {
                        currentIndex = 3;
                      },
                    );
                  },
                  child: StreamBuilder(
                    stream: AuthMethods().getUserDetails(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return const Icon(Icons.person);
                      }
                      if (!snapshot.hasData) {
                        return const Icon(Icons.person);
                      }

                      return CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          snapshot.data!.data()!['profilePicture'],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                AnimatedRoute(
                  context: context,
                  page: const AddPostPage(),
                ).createRoute(),
              );
            },
            shape: const CircleBorder(),
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

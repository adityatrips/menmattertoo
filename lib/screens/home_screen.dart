import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:men_matter_too/providers/user_provider.dart';
import 'package:men_matter_too/screens/add_post_page.dart';
import 'package:men_matter_too/screens/notification_screen.dart';
import 'package:men_matter_too/screens/posts_screen.dart';
import 'package:men_matter_too/screens/profile_page.dart';
import 'package:men_matter_too/screens/search_page.dart';
import 'package:men_matter_too/utils/create_animated_route.dart';
import 'package:men_matter_too/utils/loading_indicator.dart';
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
    return Scaffold(
      appBar: myAppBar(context),
      body: homePageBuilder(currentIndex),
      bottomNavigationBar: bottomAppBarBuilder(context),
    );
  }

  Widget homePageBuilder(int index) {
    return [
      const PostsScreen(),
      const SearchPage(),
      const NotificationScreen(),
      const ProfilePage(),
    ][currentIndex];
  }

  BottomNavigationBar bottomAppBarBuilder(BuildContext context) {
    return BottomNavigationBar(
      onTap: (newIndex) {
        setState(() {
          currentIndex = newIndex;
        });
      },
      currentIndex: currentIndex,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.secondary,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        color: Colors.white,
      ),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(
            Icons.home_rounded,
          ),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(
            Icons.search_rounded,
          ),
          label: 'Search',
        ),
        const BottomNavigationBarItem(
          icon: Icon(
            Icons.notifications_rounded,
          ),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: GestureDetector(
            onLongPress: () {
              Navigator.push(
                context,
                AnimatedRoute(
                  context: context,
                  page: const AddPostPage(),
                ).createRoute(),
              );
            },
            child: Consumer<UserProvider>(
              builder: (context, user, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    width: 30,
                    imageUrl: user.loggedUser?.profilePicture ?? "",
                    placeholder: (context, url) => const LoadingIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error_rounded),
                  ),
                );
              },
            ),
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}

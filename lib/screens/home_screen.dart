import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:men_matter_too/providers/user_provider.dart';
import 'package:men_matter_too/screens/profile_page.dart';
import 'package:men_matter_too/widgets/app_bar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  int currentIndex = 3;

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
              Center(
                child: Text("Hello"),
              ),
              Center(
                child: Text("Search"),
              ),
              Center(
                child: Text("Notifications"),
              ),
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
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: _auth.currentUser!.photoURL != null
                        ? CircleAvatar(
                            radius: 15,
                            backgroundImage: NetworkImage(
                              _auth.currentUser!.photoURL!,
                            ),
                          )
                        : const Icon(Icons.person),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: null,
            shape: const CircleBorder(),
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

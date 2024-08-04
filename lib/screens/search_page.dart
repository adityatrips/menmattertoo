import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:men_matter_too/models/models.dart';
import 'package:men_matter_too/resources/auth_methods.dart';
import 'package:men_matter_too/screens/profile_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Center(
          child: ListView(
            children: [
              const SizedBox(height: 20),
              SearchBar(
                onChanged: (value) => setState(() {
                  searchController.text = value;
                }),
                hintText: "Search using username",
                leading: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.search),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _allProfiles(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _allProfiles() {
    return FutureBuilder(
      future: AuthMethods().searchUser(
        searchController.text,
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

        return ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return _profileCard(
              user: snapshot.data![index]!,
            );
          },
        );
      },
    );
  }

  Widget _profileCard({required MyUser user}) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.doc('users/${user.uid}').snapshots(),
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

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return ProfilePage(
                    user: user,
                  );
                }),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(15),
              ),
              width: double.infinity,
              height: 150,
              child: Center(
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    CircleAvatar(
                      foregroundImage: CachedNetworkImageProvider(
                        user.profilePicture,
                      ),
                      radius: 50,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "@${user.username}",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            AuthMethods().followAndUnfollowUser(
                              selfUid: FirebaseAuth.instance.currentUser!.uid,
                              otherUid: user.uid,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              snapshot.data!['followers'].contains(
                                FirebaseAuth.instance.currentUser!.uid,
                              )
                                  ? "Unfollow"
                                  : "Follow",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

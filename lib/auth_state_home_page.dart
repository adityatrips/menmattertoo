import 'package:flutter/material.dart';
import 'package:men_matter_too/models/models.dart';
import 'package:men_matter_too/resources/auth_methods.dart';
import 'package:men_matter_too/screens/home_screen.dart';

class AuthStateHomePage extends StatefulWidget {
  const AuthStateHomePage({super.key});

  @override
  _AuthStateHomePageState createState() => _AuthStateHomePageState();
}

class _AuthStateHomePageState extends State<AuthStateHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<MyUser?>(
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
          return const HomeScreen();
        },
      ),
    );
  }
}

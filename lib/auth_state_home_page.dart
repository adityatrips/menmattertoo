import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:men_matter_too/screens/home_screen.dart';

class AuthStateHomePage extends StatefulWidget {
  const AuthStateHomePage({super.key});

  @override
  AuthStateHomePageState createState() => AuthStateHomePageState();
}

class AuthStateHomePageState extends State<AuthStateHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
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

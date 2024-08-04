import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:men_matter_too/models/models.dart';

class AuthMethods {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<MyUser?> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snapshot = await _firestore
        .collection('users')
        .doc(
          currentUser.uid,
        )
        .get();

    return MyUser.fromSnapshot(snapshot);
  }

  Future<String> signUpUser({
    required String name,
    required String password,
    required String username,
    required String email,
    required String bio,
    required String role,
  }) async {
    String res = "Some internal error occurred. Please try again later";

    try {
      final UserCredential userCred =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      MyUser user = MyUser(
        username: username,
        name: name,
        email: email,
        bio: bio,
        uid: userCred.user!.uid,
        role: role,
        followers: [],
        following: [],
        posts: [],
        profilePicture:
            "https://firebasestorage.googleapis.com/v0/b/men-matter.appspot.com/o/default_pfp.webp?alt=media",
      );

      await _firestore
          .collection(
            "users",
          )
          .doc(
            userCred.user!.uid,
          )
          .set(user.toJson());

      res = "success";
    } on FirebaseAuthException catch (err) {
      res =
          err.message ?? "Some internal error occurred. Please try again later";
    }

    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some internal error occurred. Please try again later";

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      res = "success";
    } on FirebaseAuthException catch (err) {
      res =
          err.message ?? "Some internal error occurred. Please try again later";
    }

    log(res);
    return res;
  }

  Future<String> logout() async {
    String res = "Some internal error occurred. Please try again later";
    try {
      await _auth.signOut();
      res = "success";
    } on FirebaseAuthException catch (e) {
      res = e.message ?? "Some internal error occurred. Please try again later";
    } catch (e) {
      res = "Some internal error occurred. Please try again later";
    }

    return res;
  }
}

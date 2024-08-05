import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:men_matter_too/models/models.dart';
import 'package:men_matter_too/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AuthMethods {
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      await _auth.currentUser!.updatePhotoURL(
        userCredential.user!.photoURL,
      );
      await _firestore.doc("users/${userCredential.user!.uid}").update({
        'profilePicture': userCredential.user!.photoURL,
      });

      return userCredential.user;
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  Future<String> updateProfile({
    required String name,
    required String username,
    required String bio,
    CroppedFile? file,
  }) async {
    String res = "Some internal error occurred. Please try again later";

    try {
      User currentUser = _auth.currentUser!;
      final ref = _firestore.collection('users').doc(currentUser.uid);

      if (file != null) {
        final storageRef = _storage
            .ref()
            .child('profile_pictures')
            .child(_auth.currentUser!.uid);

        final uploadTask = await storageRef.putFile(
          File(file.path),
        );

        final url = await uploadTask.ref.getDownloadURL();
        ref.update({
          'name': name,
          'username': username,
          'bio': bio,
          'profilePicture': url,
        });
      } else {
        ref.update({
          'name': name,
          'username': username,
          'bio': bio,
        });
      }

      res = "success";
    } on FirebaseAuthException catch (e) {
      res = e.message ?? "Some internal error occurred. Please try again later";
    } catch (e) {
      res = "Some internal error occurred. Please try again later";
    }

    return res;
  }

  Future<String> updateProfilePicture(CroppedFile file) async {
    String res = "Some internal error occurred. Please try again later";

    try {
      User currentUser = _auth.currentUser!;

      final ref = _firestore.collection('users').doc(currentUser.uid);
      final storageRef = _storage
          .ref()
          .child('profile_pictures')
          .child(_auth.currentUser!.uid);

      final uploadTask = await storageRef.putFile(
        File(file.path),
      );

      final url = await uploadTask.ref.getDownloadURL();

      ref.update({
        'profilePicture': url,
      });
      _auth.currentUser!.updatePhotoURL(url);

      res = "success";
    } on FirebaseAuthException catch (e) {
      res = e.message ?? "Some internal error occurred. Please try again later";
    } catch (e) {
      res = "Some internal error occurred. Please try again later";
    }

    return res;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getAllUsers() async {
    final users = await _firestore.collection("users").get();

    return users.docs;
  }

  Future<List<MyUser?>> searchUser(String searchQuery) async {
    final users = await _firestore
        .collection("users")
        .where(Filter.and(
            Filter(
              'username',
              isGreaterThanOrEqualTo: searchQuery,
            ),
            Filter(
              'username',
              isLessThanOrEqualTo: '$searchQuery\uf8ff',
            ),
            Filter(
              'uid',
              isNotEqualTo: _auth.currentUser!.uid,
            )))
        .get();

    return users.docs.map((e) {
      return MyUser.fromJson(e.data());
    }).toList();
  }

  Future<bool> isFollowing({
    required String selfUid,
    required String otherUid,
  }) async {
    final selfRef = _firestore.collection("users").doc(selfUid);
    final selfDoc = await selfRef.get();
    final selfData = selfDoc.data() as Map<String, dynamic>;

    List<dynamic> selfFollowing = selfData['following'];

    if (selfFollowing.contains(otherUid)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> followAndUnfollowUser({
    required String selfUid,
    required String otherUid,
  }) async {
    if (selfUid == otherUid) {
      log("You cannot follow yourself");
      return Future.error("You cannot follow yourself");
    }

    log("Your uid  : $selfUid");
    log("Otehr uid : $otherUid");

    final selfRef = _firestore.collection("users").doc(selfUid);
    final otherRef = _firestore.collection("users").doc(otherUid);

    final selfDoc = await selfRef.get();
    final otherDoc = await otherRef.get();

    final selfData = selfDoc.data() as Map<String, dynamic>;
    final otherData = otherDoc.data() as Map<String, dynamic>;

    List<dynamic> selfFollowing = selfData['following'];
    List<dynamic> otherFollowers = otherData['followers'];

    if (selfFollowing.contains(otherUid)) {
      selfFollowing.remove(otherUid);
      otherFollowers.remove(selfUid);
    } else {
      selfFollowing.add(otherUid);
      otherFollowers.add(selfUid);
    }

    await selfRef.update({
      'following': selfFollowing,
    });

    await otherRef.update({
      'followers': otherFollowers,
    });

    log("Following: $selfFollowing");
    log("Followers: $otherFollowers");
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetailsF(String uid) {
    return _firestore
        .collection('users')
        .doc(
          uid,
        )
        .get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() {
    User currentUser = _auth.currentUser!;

    return _firestore
        .collection('users')
        .doc(
          currentUser.uid,
        )
        .snapshots();
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

  Future<String> logout(BuildContext context) async {
    String res = "Some internal error occurred. Please try again later";
    Provider.of<UserProvider>(context, listen: false).setUser(null);
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

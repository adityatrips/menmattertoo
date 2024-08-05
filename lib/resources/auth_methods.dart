import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
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

      await addNotificationToProfile(
        uid: userCredential.user!.uid,
        notification: "You signed in with Google",
      );
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
    Uint8List? file,
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

        final uploadTask = await storageRef.putData(file);

        final url = await uploadTask.ref.getDownloadURL();
        ref.update({
          'name': name,
          'username': username,
          'bio': bio,
          'profilePicture': url,
        });
        await _auth.currentUser!.updatePhotoURL(url);
      } else {
        ref.update({
          'name': name,
          'username': username,
          'bio': bio,
        });
      }

      res = "success";
      await addNotificationToProfile(
        uid: _auth.currentUser!.uid,
        notification: "You updated your profile",
      );
    } on FirebaseAuthException catch (e) {
      res = e.message ?? "Some internal error occurred. Please try again later";
    } catch (e) {
      res = "Some internal error occurred. Please try again later";
    }

    return res;
  }

  Future<String> updateProfilePicture(Uint8List file) async {
    String res = "Some internal error occurred. Please try again later";

    try {
      User currentUser = _auth.currentUser!;

      final ref = _firestore.collection('users').doc(currentUser.uid);
      final storageRef = _storage
          .ref()
          .child('profile_pictures')
          .child(_auth.currentUser!.uid);

      final uploadTask = await storageRef.putData(file);

      final url = await uploadTask.ref.getDownloadURL();

      ref.update({
        'profilePicture': url,
      });
      _auth.currentUser!.updatePhotoURL(url);

      res = "success";
      await addNotificationToProfile(
        uid: _auth.currentUser!.uid,
        notification: "You updated your profile picture",
      );
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

  Future<String> uploadPost({
    required String title,
    required String caption,
    required Uint8List file,
  }) async {
    String res = "Some internal error occurred. Please try again later";

    try {
      final storageRef =
          _storage.ref().child('posts').child(_auth.currentUser!.uid);
      final uploadTask = await storageRef.putData(file);
      final url = await uploadTask.ref.getDownloadURL();
      final postRef = _firestore.collection('posts').doc();

      final post = Post(
        title: title,
        caption: caption,
        img: url,
        author: _auth.currentUser!.uid,
        likes: [],
        comments: [],
        postUid: postRef.id,
      );

      await _firestore.collection('posts').add(post.toJson());
      res = "success";
      await addNotificationToProfile(
        uid: _auth.currentUser!.uid,
        notification: "You uploaded a post",
      );
    } catch (e) {
      res = e.toString();
    }

    return res;
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

      await addNotificationToProfile(
        uid: _auth.currentUser!.uid,
        notification: "You unfollowed ${otherDoc.data()!['name']}",
      );
      await addNotificationToProfile(
        uid: otherDoc.id,
        notification: "${selfDoc.data()!['name']} unfollowed you",
      );
    } else {
      selfFollowing.add(otherUid);
      otherFollowers.add(selfUid);

      await addNotificationToProfile(
        uid: _auth.currentUser!.uid,
        notification: "You followed ${otherDoc.data()!['name']}",
      );
      await addNotificationToProfile(
        uid: otherDoc.id,
        notification: "${selfDoc.data()!['name']} followed you",
      );
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
          .set(
            user.toJson(),
          );

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

    await addNotificationToProfile(
      uid: _auth.currentUser!.uid,
      notification: "You signed in using email and password",
    );
    log(res);
    return res;
  }

  Future<void> addNotificationToProfile({
    required String uid,
    required String notification,
  }) {
    String timestamp = DateFormat.yMMMMd().add_jm().format(DateTime.now());

    return _firestore.collection('users').doc(uid).update({
      'notifications': FieldValue.arrayUnion(
        [
          {
            'notification': notification,
            'timestamp': timestamp,
          }
        ],
      ),
    });
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

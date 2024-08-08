import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:men_matter_too/models/models.dart';
import 'package:men_matter_too/utils/show_snackbar.dart';
import 'package:uuid/uuid.dart';

class UserProvider with ChangeNotifier {
  MyUser? _user;
  get getUser => _user;
  set setUser(MyUser user) {
    _user = user;
    notifyListeners();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<Post>? posts;
  List<MyUser>? allUsers;
  MyUser? loggedUser;
  List<MyNotification>? allNotifications;
  MyUser? userFoundByUid;
  Post? postFoundById;

  Future getUserByUid(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(
            "users",
          )
          .doc(uid)
          .get();

      if (!snapshot.exists) {
        userFoundByUid = null;
      }

      userFoundByUid = MyUser.fromSnapshot(snapshot);

      notifyListeners();
    } catch (e) {
      return Builder(
        builder: (context) {
          return SnackBar(
            content: Text(e.toString()),
          );
        },
      );
    }
  }

  Future getPostByUid(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(
            "posts",
          )
          .doc(uid)
          .get();

      if (!snapshot.exists) {
        userFoundByUid = null;
      }

      postFoundById = Post.fromSnapshot(snapshot);

      notifyListeners();
    } catch (e) {
      return Builder(
        builder: (context) {
          return SnackBar(
            content: Text(e.toString()),
          );
        },
      );
    }
  }

  Future getAllPosts() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(
          "posts",
        )
        .get();

    if (snapshot.docs.isEmpty) {
      posts = [];
    }

    posts = snapshot.docs.map((e) => Post.fromSnapshot(e)).toList();

    notifyListeners();
  }

  Future getAllUsers() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(
          "users",
        )
        .get();

    if (snapshot.docs.isEmpty) {
      allUsers = [];
    }

    allUsers = snapshot.docs.map((e) => MyUser.fromSnapshot(e)).toList();

    notifyListeners();
  }

  Future getLoggedInUser() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(
          "users",
        )
        .doc(_auth.currentUser!.uid)
        .get();

    if (!snapshot.exists || snapshot.data() == null) {
      loggedUser = null;
      notifyListeners();
      return;
    }

    loggedUser = MyUser.fromJson(snapshot.data()!);
    notifyListeners();
  }

  Future getAllNotifications() async {
    await getLoggedInUser();

    if (loggedUser == null) {
      allNotifications = [];
    }

    allNotifications = loggedUser!.notifications
        .map((e) {
          return MyNotification.fromMap(e);
        })
        .toList()
        .reversed
        .toList();

    notifyListeners();
  }

  Future uploadAndAddPost({
    required String title,
    required String caption,
    required Uint8List file,
  }) async {
    final docRef = _firestore.collection('posts').doc();
    final userRef = _firestore.collection('users').doc(_auth.currentUser!.uid);

    await userRef.update({
      'posts': FieldValue.arrayUnion([docRef]),
    });

    final storageRef = _storage.ref().child(
          'posts/${_auth.currentUser!.uid}/${docRef.id}',
        );

    final uploadTask = await storageRef.putData(
      file,
      SettableMetadata(
        contentType: "image/webp",
      ),
    );
    final url = await uploadTask.ref.getDownloadURL();

    await docRef.set(
      {
        'title': title,
        'caption': caption,
        'img': url,
        'author': userRef,
        'likes': [],
        'comments': [],
        'postUid': docRef.id,
      },
    );

    getPostByUid(docRef.id);

    await addNotifications(
      uid: _auth.currentUser!.uid,
      notification: "You uploaded a post",
    );

    showSnackbar(
      "Post uploaded successfully",
      type: TypeOfSnackbar.success,
    );

    notifyListeners();
  }

  Future editPost({
    required String uid,
    required String title,
    required String caption,
    required Uint8List? file,
    required String? url,
  }) async {
    try {
      final postRef =
          _firestore.collection('posts').doc(postFoundById!.postUid);

      if (file != null) {
        final storageRef = _storage
            .ref()
            .child('posts/${_auth.currentUser!.uid}/${postFoundById!.postUid}');

        final uploadTask = await storageRef.putData(
          file,
          SettableMetadata(
            contentType: "image/webp",
          ),
        );

        final url = await uploadTask.ref.getDownloadURL();
        postRef.update({
          'title': title,
          'caption': caption,
          'img': url,
        });
      } else {
        postRef.update({
          'title': title,
          'caption': caption,
          'img': url,
        });
      }

      await addNotifications(
        uid: _auth.currentUser!.uid,
        notification: "You updated a post",
      );

      getPostByUid(uid);
      getAllPosts();
      notifyListeners();
    } catch (e) {
      showSnackbar(
        e.toString(),
        type: TypeOfSnackbar.error,
      );
    }
  }

  Future addNotifications({
    required String uid,
    required String notification,
  }) async {
    DocumentReference userRef = _firestore.collection('users').doc(uid);

    await userRef.update(
      {
        "notifications": FieldValue.arrayUnion(
          [
            {
              "uid": const Uuid().v4(),
              "notification": notification,
              "timestamp": DateTime.now().microsecondsSinceEpoch,
            }
          ],
        )
      },
    );

    getAllNotifications();
  }

  Future updateProfile({
    required String name,
    required String username,
    required String bio,
    Uint8List? file,
  }) async {
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

      await addNotifications(
        uid: _auth.currentUser!.uid,
        notification: "You updated your profile",
      );

      getLoggedInUser();

      notifyListeners();
    } catch (e) {}
  }

  Future loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      addNotifications(
        uid: _auth.currentUser!.uid,
        notification: "You signed in using email and password",
      );

      getLoggedInUser();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackbar(
        e.message.toString(),
        type: TypeOfSnackbar.error,
      );
    } catch (e) {
      showSnackbar(
        e.toString(),
        type: TypeOfSnackbar.error,
      );
    }
  }

  Future signupUser({
    required String bio,
    required String email,
    required String name,
    required String password,
    required String role,
    required String username,
  }) async {
    try {
      QuerySnapshot<Map<String, dynamic>> usernameSnapshot = await _firestore
          .collection("users")
          .where("username", isEqualTo: username)
          .get();

      if (usernameSnapshot.docs.isNotEmpty) {
        throw "Username already exists";
      } else {
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
          notifications: [],
          profilePicture:
              "https://firebasestorage.googleapis.com/v0/b/men-matter-too-2412.appspot.com/o/default_pfp.webp?alt=media&token=b311f01b-a2e9-40c5-9f29-00e2eafcf212",
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
      }

      showSnackbar(
        "User created successfully",
        type: TypeOfSnackbar.success,
      );
      notifyListeners();
    } catch (e) {
      showSnackbar(
        e.toString(),
        type: TypeOfSnackbar.error,
      );
    }
  }

  Future logoutUser() async {
    try {
      _user = null;
      allNotifications = [];
      allUsers = [];
      loggedUser = null;
      posts = [];
      userFoundByUid = null;

      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      showSnackbar(
        e.toString(),
        type: TypeOfSnackbar.error,
      );
    } catch (e) {
      showSnackbar("$e", type: TypeOfSnackbar.error);
    }
  }

  Future resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        throw Exception("Email address can not be empty");
      }

      await _auth.sendPasswordResetEmail(email: email);
    } on Exception catch (e) {
      showSnackbar(
        e.toString(),
        type: TypeOfSnackbar.error,
      );
    }
  }

  Future markNotificationAsRead(String uuid) async {
    try {
      final userRef =
          _firestore.collection('users').doc(_auth.currentUser!.uid);
      allNotifications!.removeWhere((element) => element.uid == uuid);

      await userRef.update({
        "notifications": allNotifications!.map((e) => e.toJson()).toList(),
      });

      getAllNotifications();
    } catch (e) {
      showSnackbar(
        e.toString(),
        type: TypeOfSnackbar.error,
      );
    }
  }

  Future likeOrUnlikeAPost(String postId, String uid) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final userRef = _firestore.collection('users').doc(uid);

      final post = await postRef.get();
      final user = await userRef.get();

      if (post.data()!['likes'].contains(userRef)) {
        addNotifications(uid: uid, notification: "You unliked a post.");
        await postRef.update({
          'likes': FieldValue.arrayRemove([userRef]),
        });
      } else {
        addNotifications(uid: uid, notification: "You liked a post.");
        await postRef.update({
          'likes': FieldValue.arrayUnion([userRef]),
        });
      }
    } catch (e) {
      showSnackbar(
        e.toString(),
        type: TypeOfSnackbar.error,
      );
    }
    getPostByUid(postId);
    getUserByUid(uid);
    notifyListeners();
  }

  Future followOrUnfollowUser(String selfUid, String otherUid) async {
    try {
      if (selfUid == otherUid) {
        throw Exception("You can't follow yourself");
      }

      final selfRef = _firestore.collection('users').doc(selfUid);
      final otherRef = _firestore.collection('users').doc(otherUid);

      final self = MyUser.fromSnapshot(await selfRef.get());
      final other = MyUser.fromSnapshot(await otherRef.get());

      if (self.following.contains(otherRef)) {
        addNotifications(
          uid: selfUid,
          notification: "You unfollowed ${other.name}",
        );
        addNotifications(
          uid: otherUid,
          notification: "${self.name} unfollowed you.",
        );
        await selfRef.update({
          'following': FieldValue.arrayRemove([otherRef]),
        });

        await otherRef.update({
          'followers': FieldValue.arrayRemove([selfRef]),
        });
      } else {
        addNotifications(
          uid: selfUid,
          notification: "You followed ${other.name}",
        );
        addNotifications(
          uid: otherUid,
          notification: "${self.name} followed you.",
        );
        await selfRef.update({
          'following': FieldValue.arrayUnion([otherRef]),
        });

        await otherRef.update({
          'followers': FieldValue.arrayUnion([selfRef]),
        });
      }

      getUserByUid(selfUid);
      getUserByUid(otherUid);

      notifyListeners();
    } catch (e) {
      showSnackbar(
        e.toString(),
        type: TypeOfSnackbar.error,
      );
    }
  }
}

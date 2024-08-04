import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String username, name, email, bio, uid, role;
  final List<dynamic> followers;
  final List<dynamic> following;
  final List<dynamic> posts;
  final String profilePicture;

  MyUser({
    required this.username,
    required this.name,
    required this.email,
    required this.bio,
    required this.uid,
    required this.role,
    required this.profilePicture,
    required this.followers,
    required this.following,
    required this.posts,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "name": name,
        "email": email,
        "bio": bio,
        "uid": uid,
        "role": role,
        "profilePicture": profilePicture,
        "followers": [],
        "following": [],
        "posts": []
      };

  static MyUser fromJson(Map<String, dynamic> json) {
    return MyUser(
      username: json["username"],
      name: json["name"],
      email: json["email"],
      bio: json["bio"],
      uid: json["uid"],
      role: json["role"],
      profilePicture: json["profilePicture"],
      followers: json["followers"],
      following: json["following"],
      posts: json["posts"],
    );
  }

  static MyUser fromSnapshot(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;

    return MyUser(
      username: snap["username"],
      name: snap["name"],
      email: snap["email"],
      bio: snap["bio"],
      uid: snap["uid"],
      role: snap["role"],
      profilePicture: snap["profilePicture"],
      followers: List<dynamic>.from(snap["followers"]),
      following: List<dynamic>.from(snap["following"]),
      posts: List<dynamic>.from(snap["posts"]),
    );
  }
}

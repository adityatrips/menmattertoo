import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String username, name, email, bio, uid, role;
  final List<DocumentReference> followers;
  final List<DocumentReference> following;
  final List<DocumentReference> posts;
  final String profilePicture;
  final List<dynamic> notifications;

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
    required this.notifications,
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
        "posts": [],
        "notifications": [],
      };

  static MyUser fromJson(Map json) {
    return MyUser(
      username: json["username"],
      name: json["name"],
      email: json["email"],
      bio: json["bio"],
      uid: json["uid"],
      role: json["role"],
      profilePicture: json["profilePicture"],
      followers: List.from(json["followers"]),
      following: List.from(json["following"]),
      posts: List.from(json["posts"]),
      notifications: json["notifications"],
    );
  }

  static List<MyUser> fromList(List list) {
    return list.map(
      (e) {
        return MyUser(
          username: e["username"],
          name: e["name"],
          email: e["email"],
          bio: e["bio"],
          uid: e["uid"],
          role: e["role"],
          profilePicture: e["profilePicture"],
          followers: e["followers"],
          following: e["following"],
          posts: e["posts"],
          notifications: e["notifications"],
        );
      },
    ).toList();
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
      followers: List.from(snap["followers"]),
      following: List.from(snap["following"]),
      posts: List.from(snap["posts"]),
      notifications: List<dynamic>.from(snap["notifications"]),
    );
  }
}

class MyNotification {
  final String uid;
  final String notification;
  final int timestamp;

  MyNotification({
    required this.uid,
    required this.notification,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "notification": notification,
        "timestamp": timestamp,
      };

  static List<MyNotification> fromList(List<dynamic> list) {
    return list.map((e) => MyNotification.fromMap(e)).toList();
  }

  static MyNotification fromMap(Map<String, dynamic> map) {
    return MyNotification(
      uid: map["uid"],
      notification: map["notification"],
      timestamp: map["timestamp"],
    );
  }

  static MyNotification fromSnapshot(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;

    return MyNotification(
      uid: snap["uid"],
      notification: snap["notification"],
      timestamp: snap["timestamp"],
    );
  }
}

class Comment {
  final String text;
  final DocumentReference author;
  final String name;
  final String username;
  final String profilePicture;
  final String commentUid;

  Comment({
    required this.text,
    required this.author,
    required this.name,
    required this.username,
    required this.profilePicture,
    required this.commentUid,
  });

  Map<String, dynamic> toJson() => {
        "text": text,
        "author": author,
        "name": name,
        "username": username,
        "profilePicture": profilePicture,
        "commentUid": commentUid,
      };

  static Comment fromMap(Map<String, dynamic> map) {
    return Comment(
      text: map["text"],
      author: map["author"],
      name: map["name"],
      username: map["username"],
      profilePicture: map["profilePicture"],
      commentUid: map["commentUid"],
    );
  }

  static Comment fromSnapshot(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;

    return Comment(
      text: snap["text"],
      author: snap["author"],
      name: snap["name"],
      username: snap["username"],
      profilePicture: snap["profilePicture"],
      commentUid: snap["commentUid"],
    );
  }
}

class Post {
  final String title;
  final String caption;
  final String img;
  final DocumentReference author;
  final String postUid;
  final List<DocumentReference> likes;
  final List<Comment> comments;

  Post({
    required this.title,
    required this.caption,
    required this.img,
    required this.author,
    required this.postUid,
    required this.likes,
    required this.comments,
  });

  Map<String, dynamic> toJson() => {
        "title": title,
        "caption": caption,
        "img": img,
        "author": author,
        "postUid": postUid,
        "likes": likes,
        "comments": comments,
      };

  static Post fromMap(Map<String, dynamic> map) {
    return Post(
      title: map["title"],
      caption: map["caption"],
      img: map["img"],
      author: map["author"],
      postUid: map["postUid"],
      likes: List.from(map["likes"]),
      comments: List.from(map["comments"]),
    );
  }

  static Post fromSnapshot(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;
    return Post(
      title: snap["title"],
      caption: snap["caption"],
      img: snap["img"],
      author: snap["author"],
      postUid: snap["postUid"],
      likes: List.from(snap["likes"]),
      comments: List.from(snap["comments"]),
    );
  }
}

class PostAuthor {
  final Post posts;
  final MyUser user;

  PostAuthor({
    required this.posts,
    required this.user,
  });

  Map<String, dynamic> toJson() => {
        "posts": posts,
        "user": user,
      };

  static PostAuthor fromMap(Map<String, dynamic> map) {
    return PostAuthor(
      posts: Post.fromMap(map["posts"]),
      user: MyUser.fromJson(map["user"]),
    );
  }
}

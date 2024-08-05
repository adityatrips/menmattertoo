import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:men_matter_too/models/models.dart';
import 'package:men_matter_too/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  MyUser? _user;

  Future<String> getAndSetUser(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot;

    documentSnapshot = await AuthMethods().getUserDetailsF(uid);

    if (documentSnapshot.exists) {
      _user = MyUser.fromSnapshot(documentSnapshot);
      return 'success';
    }

    return 'error';
  }

  void setUser(MyUser? user) {
    _user = user;
    notifyListeners();
  }
}

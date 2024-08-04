import 'package:flutter/material.dart';
import 'package:men_matter_too/models/models.dart';

class UserProvider with ChangeNotifier {
  MyUser? _user;

  MyUser? getUser() {
    return _user;
  }

  void setUser(MyUser user) {
    _user = user;
    notifyListeners();
  }
}

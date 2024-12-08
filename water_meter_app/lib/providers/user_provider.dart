

import 'package:flutter/material.dart';
import 'package:water_meter_app/models/usersModel.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
      id: '',
      name: '',
      email: '',
      password: '',
      token: ''
    );

    User get user => _user;

    void setUser(String user) {
      _user = User.fromJson(user);
      notifyListeners();
    }

    void setUserFromModel(User user){
      _user = user;
      notifyListeners();
    }

}
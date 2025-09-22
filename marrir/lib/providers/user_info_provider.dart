import 'package:flutter/material.dart';

class UserInfoProvider extends ChangeNotifier {
  String? _firstName;
  String? _lastName;

  String? get fullName =>
      (_firstName != null && _lastName != null) ? "$_firstName $_lastName" : null;

  void setUserName({required String firstName, required String lastName}) {
    _firstName = firstName;
    _lastName = lastName;
    notifyListeners();
  }

  void clear() {
    _firstName = null;
    _lastName = null;
    notifyListeners();
  }
}

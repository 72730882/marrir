import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String? _role;
  bool _isLoggedIn = false;

  // Getter for role
  String? get userRole => _role;

  // Getter for login status
  bool get isLoggedIn => _isLoggedIn;

  // Load user info from SharedPreferences (used in splash screen)
  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _role = prefs.getString('user_role'); // match your login code
    _isLoggedIn = _role != null; // if role exists, user is logged in
    notifyListeners();
  }

  // Login function to save role and login status
  Future<void> login(String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _role = role;
    _isLoggedIn = true;
    await prefs.setString('user_role', role); // match login key
    notifyListeners();
  }

  // Logout function to clear role and login status
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _role = null;
    _isLoggedIn = false;
    await prefs.remove('user_role');
    notifyListeners();
  }
}

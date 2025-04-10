import 'package:flutter/material.dart';

/// A ChangeNotifier to manage dark/light theme state
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  /// Getter for current theme state
  bool get isDarkMode => _isDarkMode;

  /// Toggles between dark and light mode
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

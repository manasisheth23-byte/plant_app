import 'package:flutter/material.dart';

class UnreadNotificationProvider with ChangeNotifier {
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  void setUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }
  void incrementUnreadCount() {
    _unreadCount += 1;
    notifyListeners();
  }
}

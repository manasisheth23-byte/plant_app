
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/io.dart';

class Constant{
  static var txt = TextEditingController();
  static bool isSelected = false;
  static WebSocket? rawSocket;
  static int? unreadCount;
  static IOWebSocketChannel? channel;
}
import 'package:flutter/services.dart';

class BatteryOptimization {
  static const MethodChannel _channel =
  MethodChannel('com.cloud9.plantapp/battery');

  static Future<bool> isDisabled() async {
    return await _channel.invokeMethod('isIgnoringBatteryOptimizations');
  }
}
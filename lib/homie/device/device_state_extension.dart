
import 'package:flutter/material.dart';
import 'package:flutter_homie/homie/device/device_model.dart';

extension HomieDeviceStateDecorated on HomieDeviceState {
  Color get toColor {
    switch (this) {
      case HomieDeviceState.init:
        return Colors.greenAccent;
      case HomieDeviceState.ready:
        return Colors.lightGreen;
      case HomieDeviceState.disconnected:
        return Colors.redAccent;
      case HomieDeviceState.sleeping:
        return Colors.amberAccent;
      case HomieDeviceState.lost:
        return Colors.red;

      case HomieDeviceState.alert:
      default:
        return Colors.deepOrangeAccent;
    }
  }

  String get toName {
    switch (this) {
      case HomieDeviceState.init:
        return 'Init';
      case HomieDeviceState.ready:
        return 'Ready';
      case HomieDeviceState.disconnected:
        return 'Disconnected';
      case HomieDeviceState.sleeping:
        return 'Sleeping';
      case HomieDeviceState.lost:
        return 'Lost';

      case HomieDeviceState.alert:
      default:
        return 'Alert';
    }
  }

  static HomieDeviceState fromString(String s) {
    return HomieDeviceState.values
        .firstWhere((element) => element.toString().endsWith('.$s'), orElse: () => HomieDeviceState.alert);
  }
}
import 'package:equatable/equatable.dart';
import 'package:flutter_homie/homie/device/device_model.dart';

abstract class DeviceInfoEvent extends Equatable {
  const DeviceInfoEvent();

  @override
  List<Object> get props => [];
}

class DeviceInfoOpened extends DeviceInfoEvent {
  final String deviceId;

  DeviceInfoOpened(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}

class DeviceInfoRenewed extends DeviceInfoEvent {
  final HomieDeviceState state;
  DeviceInfoRenewed(this.state);

  @override
  List<Object> get props => [state];

}
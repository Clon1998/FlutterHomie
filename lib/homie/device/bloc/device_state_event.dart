import 'package:equatable/equatable.dart';
import 'package:flutter_homie/homie/device/device_model.dart';

abstract class DeviceStateEvent extends Equatable {
  const DeviceStateEvent();
}

class DeviceStateFetchingStarted extends DeviceStateEvent {
  final String deviceId;

  DeviceStateFetchingStarted({this.deviceId});

  @override
  List<Object> get props => [deviceId];
}

class DeviceStateReceived extends DeviceStateEvent {
  final HomieDeviceState deviceState;

  DeviceStateReceived(this.deviceState);

  @override
  List<Object> get props => [deviceState];
}

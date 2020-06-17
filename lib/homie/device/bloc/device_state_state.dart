import 'package:equatable/equatable.dart';
import 'package:flutter_homie/homie/device/device_model.dart';

abstract class DeviceStateState extends Equatable {
  const DeviceStateState();

  @override
  List<Object> get props => [];
}

class DeviceStateInitial extends DeviceStateState {}

class DeviceStateCurrent extends DeviceStateState {
  final HomieDeviceState deviceState;

  DeviceStateCurrent(this.deviceState);
  List<Object> get props => [deviceState];
}

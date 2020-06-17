import 'package:equatable/equatable.dart';

import '../device_model.dart';

abstract class DeviceInfoState extends Equatable {
  const DeviceInfoState();

  @override
  List<Object> get props => [];
}

class DeviceInfoInitial extends DeviceInfoState {}

class DeviceInfoLoading extends DeviceInfoState {}

class DeviceInfoResult extends DeviceInfoState {
  final DeviceModel deviceModel;
  final HomieDeviceState deviceState;

  DeviceInfoResult({this.deviceModel, this.deviceState});

  @override
  List<Object> get props => [deviceModel, deviceState];
}

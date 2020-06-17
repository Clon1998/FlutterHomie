import 'package:equatable/equatable.dart';

import '../device_discover_model.dart';

abstract class DeviceDiscoveryState extends Equatable {
  const DeviceDiscoveryState();

  @override
  List<Object> get props => [];
}

class DeviceDiscoveryInitial extends DeviceDiscoveryState {
}

class DeviceDiscoveryLoading extends DeviceDiscoveryState {
}

class DeviceDiscoveryResult extends DeviceDiscoveryState {
  final Set<DeviceDiscoverModel> devices;
  DeviceDiscoveryResult({this.devices});

  @override
  List<Object> get props => [devices];
}

class DeviceDiscoveryStop extends DeviceDiscoveryState {
  final Set<DeviceDiscoverModel> devices;
  DeviceDiscoveryStop({this.devices});

  @override
  List<Object> get props => [devices];
}
import 'package:equatable/equatable.dart';

import '../device_discover_model.dart';

abstract class DeviceDiscoveryEvent extends Equatable {
  const DeviceDiscoveryEvent();

  @override
  List<Object> get props => [];
}
class DeviceDiscoveryStarted extends DeviceDiscoveryEvent{

}

class DeviceDiscoveryStopped extends DeviceDiscoveryEvent{

}

class DeviceDiscoveryNewDeviceDiscovered extends DeviceDiscoveryEvent {
  final DeviceDiscoverModel device;

  DeviceDiscoveryNewDeviceDiscovered(this.device);

  @override
  List<Object> get props => [device];
}
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_homie/data/mqtt_data_provider.dart';
import 'package:flutter_homie/dependency_injection.dart';
import 'package:flutter_homie/homie/device/device_discover_model.dart';
import 'bloc.dart';

class DiscoverDeviceBloc extends Bloc<DeviceDiscoveryEvent, DeviceDiscoveryState> {
  DiscoverDeviceBloc([MqttDataProvider mqttDataProvider]) : _mqttDataProvider = mqttDataProvider ?? getIt<MqttDataProvider>();

  @override
  DeviceDiscoveryState get initialState => DeviceDiscoveryInitial();

  final MqttDataProvider _mqttDataProvider;

  StreamSubscription _subscription;

  Set<DeviceDiscoverModel> _discoveredDevices = Set();

  @override
  Stream<DeviceDiscoveryState> mapEventToState(
    DeviceDiscoveryEvent event,
  ) async* {
    if (event is DeviceDiscoveryStarted) {
      yield DeviceDiscoveryLoading();
      _discoveredDevices.clear();
      _subscription?.cancel();

      var discDeviceStream = await _mqttDataProvider.getDiscoveryResult();
      _subscription = discDeviceStream.listen((event) {
        add(DeviceDiscoveryNewDeviceDiscovered(event));
      });
    }

    if (event is DeviceDiscoveryNewDeviceDiscovered) {
      _discoveredDevices.add(event.device);
      yield DeviceDiscoveryResult(
        devices: Set.of(_discoveredDevices),//Figure out a better way of doing this! Since i dont really like always coping this! But if i use the reference to this list, the Equatable will think, that it is the same!
      );
    }

    if (event is DeviceDiscoveryStopped) {
      _subscription?.cancel();

      yield DeviceDiscoveryStop(devices: _discoveredDevices);
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_homie/data/mqtt_data_provider.dart';
import 'package:flutter_homie/dependency_injection.dart';
import 'package:flutter_homie/homie/device/device_state_extension.dart';
import 'package:flutter_homie/homie/device/device_discover_model.dart';

import './bloc.dart';

class DeviceStateBloc extends Bloc<DeviceStateEvent, DeviceStateState> {
  DeviceStateBloc([MqttDataProvider mqttDataProvider]) : _mqttDataProvider = mqttDataProvider ?? getIt<MqttDataProvider>();

  final MqttDataProvider _mqttDataProvider;

  @override
  DeviceStateState get initialState => DeviceStateInitial();

  StreamSubscription<String> stateStreamSubscription;

  @override
  Stream<DeviceStateState> mapEventToState(
    DeviceStateEvent event,
  ) async* {
    if (event is DeviceStateFetchingStarted) {
      Stream<String> stateStream = await _mqttDataProvider.getDynamicDeviceAttribute(event.deviceId, '\$state');
      stateStreamSubscription?.cancel();

      stateStreamSubscription = stateStream.listen((event) {
        add(DeviceStateReceived(HomieDeviceStateDecorated.fromString(event)));
      });
    }
    if (event is DeviceStateReceived) {
      yield DeviceStateCurrent(event.deviceState);
    }
  }

  @override
  Future<void> close() async {
    await stateStreamSubscription?.cancel();
    return super.close();
  }
}

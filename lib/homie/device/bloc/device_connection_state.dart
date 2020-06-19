import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_homie/data/mqtt_data_provider.dart';
import 'package:flutter_homie/dependency_injection.dart';
import 'package:flutter_homie/homie/device/device_model.dart';
import 'package:flutter_homie/homie/device/device_state_extension.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_connection_state.freezed.dart';

@freezed
abstract class DeviceConnectionState with _$DeviceConnectionState {
  const factory DeviceConnectionState.initial() = DeviceConnectionStateInitial;

  const factory DeviceConnectionState.current(HomieDeviceState deviceState) = DeviceConnectionStateCurrente;
}

@freezed
abstract class DeviceConnectionStateEvent with _$DeviceConnectionStateEvent {
  const factory DeviceConnectionStateEvent.requested(String deviceId) = DeviceConnectionStateEventRequested;

  const factory DeviceConnectionStateEvent.renewed(HomieDeviceState state) = DeviceConnectionStateEventRenewed;
}

class DeviceConnectionStateBloc extends Bloc<DeviceConnectionStateEvent, DeviceConnectionState> {
  DeviceConnectionStateBloc([MqttDataProvider mqttDataProvider])
      : _mqttDataProvider = mqttDataProvider ?? getIt<MqttDataProvider>();

  final MqttDataProvider _mqttDataProvider;

  @override
  DeviceConnectionState get initialState => DeviceConnectionState.initial();

  StreamSubscription<String> stateStreamSubscription;

  @override
  Stream<DeviceConnectionState> mapEventToState(
    DeviceConnectionStateEvent event,
  ) async* {
    yield* event.maybeWhen(
        orElse: () async* {},
        requested: (deviceId) async* {
          Stream<String> stateStream = await _mqttDataProvider.getDeviceAttributeAsStream(deviceId, '\$state');
          stateStreamSubscription?.cancel();

          stateStreamSubscription = stateStream.listen((event) {
            add(DeviceConnectionStateEvent.renewed(HomieDeviceStateDecorated.fromString(event)));
          });
        },
        renewed: (state) async* {
          yield DeviceConnectionState.current(state);
        });
  }

  @override
  Future<void> close() async {
    await stateStreamSubscription?.cancel();
    return super.close();
  }
}

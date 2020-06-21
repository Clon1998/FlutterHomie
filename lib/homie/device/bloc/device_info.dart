import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/data/homie_data_provider.dart';
import 'package:flutter_homie/data/mqtt_data_provider.dart';
import 'package:flutter_homie/dependency_injection.dart';
import 'package:flutter_homie/exception/homie_exception.dart';
import 'package:flutter_homie/homie/device/bloc/bloc.dart';
import 'package:flutter_homie/homie/device/bloc/device_connection_state.dart';
import 'package:flutter_homie/homie/device/device_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_info.freezed.dart';

@freezed
abstract class DeviceInfoState with _$DeviceInfoState {
  const factory DeviceInfoState.initial() = DeviceInfoStateInitial;

  const factory DeviceInfoState.loading() = DeviceInfoStateLoading;

  const factory DeviceInfoState.result({DeviceModel deviceModel, HomieDeviceState deviceState}) = DeviceInfoStateResult;

  const factory DeviceInfoState.failure(HomieException homieException) = DeviceInfoStateFailure;
}

@freezed
abstract class DeviceInfoEvent with _$DeviceInfoEvent {
  const factory DeviceInfoEvent.opened(String deviceId) = DeviceInfoEventOpened;

  const factory DeviceInfoEvent.renewed(HomieDeviceState state) = DeviceInfoEventRenewed;
}

class DeviceInfoBloc extends Bloc<DeviceInfoEvent, DeviceInfoState> {
  final DeviceConnectionStateBloc _deviceStateBloc;
  final HomieDataProvider _mqttDataProvider;

  StreamSubscription<DeviceConnectionState> stateStreamSubscription;
  HomieDeviceState _deviceStateCurrent = HomieDeviceState.alert;

  DeviceInfoBloc(this._deviceStateBloc, [HomieDataProvider mqttDataProvider])
      : _mqttDataProvider = mqttDataProvider ?? getIt<MqttDataProvider>() {
    stateStreamSubscription = _deviceStateBloc.listen((state) {
      if (state is DeviceConnectionStateCurrente) {
        this.add(DeviceInfoEvent.renewed(state.deviceState));
      }
    });
  }

  @override
  DeviceInfoState get initialState => DeviceInfoState.initial();

  @override
  Stream<DeviceInfoState> mapEventToState(
    DeviceInfoEvent event,
  ) async* {
    yield* event.maybeWhen(
        orElse: () async* {},
        opened: (deviceId) async* {
          yield DeviceInfoState.loading();
          yield (await _mqttDataProvider.getDeviceModel(deviceId)).fold((HomieException e) => DeviceInfoState.failure(e),
              (model) => DeviceInfoState.result(deviceModel: model, deviceState: _deviceStateCurrent));
        },
        renewed: (connectionState) async* {
          _deviceStateCurrent = connectionState;
          if (state is DeviceInfoStateResult) {
            var s = state as DeviceInfoStateResult;
            yield DeviceInfoStateResult(
              deviceModel: s.deviceModel,
              deviceState: _deviceStateCurrent,
            );
          }
        });
  }

  @override
  Future<void> close() async {
    await stateStreamSubscription?.cancel();
    return super.close();
  }
}

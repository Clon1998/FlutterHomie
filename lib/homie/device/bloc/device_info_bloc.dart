import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_homie/data/mqtt_data_provider.dart';
import 'package:flutter_homie/dependency_injection.dart';
import 'package:flutter_homie/homie/device/device_model.dart';
import 'package:flutter_homie/homie/device/device_discover_model.dart';
import './bloc.dart';

class DeviceInfoBloc extends Bloc<DeviceInfoEvent, DeviceInfoState> {
  final DeviceStateBloc _deviceStateBloc;
  final MqttDataProvider _mqttDataProvider;

  StreamSubscription<DeviceStateState> stateStreamSubscription;
  HomieDeviceState _deviceStateCurrent = HomieDeviceState.alert;

  DeviceInfoBloc(this._deviceStateBloc, [MqttDataProvider mqttDataProvider])
      : _mqttDataProvider = mqttDataProvider ?? getIt<MqttDataProvider>() {
    stateStreamSubscription = _deviceStateBloc.listen((state) {
      if (state is DeviceStateCurrent) {
        this.add(DeviceInfoRenewed(state.deviceState));
      }
    });
  }

  @override
  DeviceInfoState get initialState => DeviceInfoInitial();

  @override
  Stream<DeviceInfoState> mapEventToState(
    DeviceInfoEvent event,
  ) async* {
    if (event is DeviceInfoOpened) {
      yield DeviceInfoLoading();
      DeviceModel deviceModel = await _mqttDataProvider.getDeviceModel(event.deviceId);
      yield DeviceInfoResult(deviceModel: deviceModel, deviceState: _deviceStateCurrent);
    }

    if (event is DeviceInfoRenewed) {
      _deviceStateCurrent = event.state;
      if (state is DeviceInfoResult) {
        var s = state as DeviceInfoResult;
        yield DeviceInfoResult(
          deviceModel: s.deviceModel,
          deviceState: _deviceStateCurrent,
        );
      }
    }
  }

  @override
  Future<void> close() async {
    await stateStreamSubscription?.cancel();
    return super.close();
  }
}

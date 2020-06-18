import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_homie/data/mqtt_data_provider.dart';
import 'package:flutter_homie/dependency_injection.dart';
import 'package:flutter_homie/exception/homie_exception.dart';
import 'package:flutter_homie/homie/device/device_discover_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'bloc.dart';

part 'device_discovery.freezed.dart';

@freezed
abstract class DeviceDiscoveryState with _$DeviceDiscoveryState {
  const factory DeviceDiscoveryState.initial() = DeviceDiscoveryStateInitial;

  const factory DeviceDiscoveryState.loading() = DeviceDiscoveryStateLoading;

  const factory DeviceDiscoveryState.failure(HomieException exception) = DeviceDiscoveryStateFailure;

  const factory DeviceDiscoveryState.active(Set<DeviceDiscoverModel> devices) = DeviceDiscoveryStateActive;

  const factory DeviceDiscoveryState.stop(Set<DeviceDiscoverModel> devices) = DeviceDiscoveryStateStop;
}

@freezed
abstract class DeviceDiscoveryEvent with _$DeviceDiscoveryEvent {
  const factory DeviceDiscoveryEvent.started() = DeviceDiscoveryEventStarted;

  const factory DeviceDiscoveryEvent.stopped() = DeviceDiscoveryEventStopped;

  const factory DeviceDiscoveryEvent.discovered(DeviceDiscoverModel device) = DeviceDiscoveryEventDiscovered;
}

class DiscoverDeviceBloc extends Bloc<DeviceDiscoveryEvent, DeviceDiscoveryState> {
  DiscoverDeviceBloc([MqttDataProvider mqttDataProvider]) : _mqttDataProvider = mqttDataProvider ?? getIt<MqttDataProvider>();

  @override
  DeviceDiscoveryState get initialState => DeviceDiscoveryState.initial();

  final MqttDataProvider _mqttDataProvider;

  StreamSubscription _subscription;

  Set<DeviceDiscoverModel> _discoveredDevices = Set();

  Stream<DeviceDiscoveryState> _start() async* {
    yield DeviceDiscoveryState.loading();
    _discoveredDevices.clear();
    _subscription?.cancel();

    var either = await _mqttDataProvider.getDiscoveryResult();
    yield* either.fold((HomieException e) async* {
      yield DeviceDiscoveryState.failure(e);
    }, (results) async* {
      _subscription = results.listen((event) {
        add(DeviceDiscoveryEvent.discovered(event));
      });
    });
  }

  Stream<DeviceDiscoveryState> _stop() async* {
    _subscription?.cancel();

    yield DeviceDiscoveryState.stop(_discoveredDevices);
  }

  Stream<DeviceDiscoveryState> _discovery(DeviceDiscoverModel deviceDiscoverModel) async* {
    _discoveredDevices.add(deviceDiscoverModel);
    yield DeviceDiscoveryState.active(
      Set.of(
          _discoveredDevices), //Figure out a better way of doing this! Since i dont really like always coping this! But if i use the reference to this list, the Equatable will think, that it is the same!
    );
  }

  @override
  Stream<DeviceDiscoveryState> mapEventToState(
    DeviceDiscoveryEvent event,
  ) {
    return event.when(started: _start, stopped: _stop, discovered: _discovery);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

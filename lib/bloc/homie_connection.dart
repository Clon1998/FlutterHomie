import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/bloc/bloc.dart';
import 'package:flutter_homie/data/model/settings_model.dart';
import 'package:flutter_homie/data/mqtt_data_provider.dart';
import 'package:flutter_homie/dependency_injection.dart';
import 'package:flutter_homie/exception/homie_exception.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mqtt_client/mqtt_client.dart';

part 'homie_connection.freezed.dart';

@freezed
abstract class HomieConnectionState with _$HomieConnectionState {
  const factory HomieConnectionState.initial() = HomieConnectionStateInitial;

  const factory HomieConnectionState.loading() = HomieConnectionStateLoading;

  const factory HomieConnectionState.failure(HomieException exception) = HomieConnectionStateFailure;

  const factory HomieConnectionState.active() = HomieConnectionStateActive;
}

@freezed
abstract class HomieConnectionEvent with _$HomieConnectionEvent {
  const factory HomieConnectionEvent.ping() = HomieConnectionEventPing;

  const factory HomieConnectionEvent.open(SettingsModel settingsModel) = HomieConnectionEventOpen;

  const factory HomieConnectionEvent.close() = HomieConnectionEventClose;
}

class HomieConnectionBloc extends Bloc<HomieConnectionEvent, HomieConnectionState> {
  final MqttDataProvider _mqttDataProvider;

  StreamSubscription<MqttSettingsState> streamSubscription;

  HomieConnectionBloc([MqttDataProvider mqttDataProvider]) : _mqttDataProvider = mqttDataProvider ?? getIt<MqttDataProvider>() {
    streamSubscription = getIt<MqttSettingsBloc>().listen((settingsState) {
      if (settingsState is MqttSettingsCurrent) {
        this.add(HomieConnectionEvent.open(settingsState.settingsModel));
      }
    });
  }

  @override
  HomieConnectionState get initialState => HomieConnectionState.initial();

  Stream<HomieConnectionState> _ping() async* {
    yield HomieConnectionState.loading();
    if (_mqttDataProvider.client != null && _mqttDataProvider.client.connectionStatus.state == MqttConnectionState.connected)
      yield HomieConnectionState.active();
    else
      yield HomieConnectionState.failure(
          HomieException.mqttConnectionError('ConnectionStatus: ${_mqttDataProvider.client?.connectionStatus}'));
  }

  Stream<HomieConnectionState> _open(SettingsModel settingsModel) async* {
    yield HomieConnectionState.loading();
    Either<HomieException, MqttClientConnectionStatus> mqttClientConnectionStatus =
        await _mqttDataProvider.tryConnect(settingsModel);

    yield* mqttClientConnectionStatus.fold((HomieException exception) async* {
      yield HomieConnectionState.failure(exception);
    }, (status) async* {
      yield HomieConnectionState.active();
    });
  }

  @override
  Stream<HomieConnectionState> mapEventToState(HomieConnectionEvent event) {
    return event.when(ping: _ping, open: _open, close: () => null);
  }

  @override
  Future<void> close() {
    streamSubscription?.cancel();
    return super.close();
  }
}
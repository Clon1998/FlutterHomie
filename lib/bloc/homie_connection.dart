import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/bloc/mqtt_setting.dart';
import 'package:flutter_homie/data/homie_data_provider.dart';
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

  const factory HomieConnectionState.disconnected() = HomieConnectionStateClose;
}

@freezed
abstract class HomieConnectionEvent with _$HomieConnectionEvent {
  const factory HomieConnectionEvent.ping() = HomieConnectionEventPing;

  const factory HomieConnectionEvent.open(SettingsModel settingsModel) = HomieConnectionEventOpen;

  const factory HomieConnectionEvent.close() = HomieConnectionEventClose;
}

class HomieConnectionBloc extends Bloc<HomieConnectionEvent, HomieConnectionState> {
  final HomieDataProvider _mqttDataProvider;

  StreamSubscription<MqttSettingsState> streamSubscription;

  HomieConnectionBloc([HomieDataProvider mqttDataProvider]) : _mqttDataProvider = mqttDataProvider ?? getIt<MqttDataProvider>() {
    _mqttDataProvider.onDisconnect(_onClientDisconnect);

    streamSubscription = getIt<MqttSettingsBloc>().listen((settingsState) {
      settingsState.maybeWhen(
          orElse: () => null,
          available: (SettingsModel model) {
            add(HomieConnectionEvent.open(model));
          });
    });
  }

  void _onClientDisconnect(MqttClientConnectionStatus status) {
    if (status.state == MqttConnectionState.disconnected && status.returnCode == MqttConnectReturnCode.connectionAccepted)
      add(HomieConnectionEvent.close());
  }

  @override
  HomieConnectionState get initialState => HomieConnectionState.initial();

  Stream<HomieConnectionState> _ping() async* {
    yield HomieConnectionState.loading();
    var checkConnection = _mqttDataProvider.checkConnection();

    if (checkConnection == null) {
      yield HomieConnectionState.active();
    } else {
      yield HomieConnectionState.failure(HomieException.mqttConnectionError('ConnectionStatus: $checkConnection'));
    }
  }

  Stream<HomieConnectionState> _open(SettingsModel settingsModel) async* {
    yield HomieConnectionState.loading();
    Either<HomieException, MqttClientConnectionStatus> mqttClientConnectionStatus =
        await _mqttDataProvider.tryConnect(settingsModel);

    yield mqttClientConnectionStatus.fold((HomieException exception) {
      return HomieConnectionState.failure(exception);
    }, (status) {
      return HomieConnectionState.active();
    });
  }

  Stream<HomieConnectionState> _close() async* {
    yield HomieConnectionState.disconnected();
  }

  @override
  Stream<HomieConnectionState> mapEventToState(HomieConnectionEvent event) {
    return event.when(ping: _ping, open: _open, close: _close);
  }

  @override
  Future<void> close() {
    streamSubscription?.cancel();
    return super.close();
  }
}

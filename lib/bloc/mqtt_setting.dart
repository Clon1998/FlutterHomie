import 'package:flutter_homie/data/model/settings_model.dart';
import 'package:flutter_homie/exception/homie_exception.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'mqtt_setting.freezed.dart';

@freezed
abstract class MqttSettingsState with _$MqttSettingsState {
  const factory MqttSettingsState.initial() = MqttSettingsStateInitial;

  const factory MqttSettingsState.loading() = MqttSettingsStateLoading;

  const factory MqttSettingsState.failure(HomieException exception) = MqttSettingsStateFailure;

  const factory MqttSettingsState.available(SettingsModel settingsModel) = MqttSettingsStateAvailable;
}

@freezed
abstract class MqttSettingsEvent with _$MqttSettingsEvent {
  const factory MqttSettingsEvent.retrieved(SettingsModel settingsModel) = MqttSettingsEventRetrieved;

  const factory MqttSettingsEvent.test() = MqttSettingsEventTest;
}

import 'package:equatable/equatable.dart';
import 'package:flutter_homie/data/model/settings_model.dart';

abstract class MqttSettingsEvent extends Equatable {
  const MqttSettingsEvent();

  @override
  List<Object> get props => [];
}

class MqttSettingsUpdated extends MqttSettingsEvent {
  final SettingsModel settingsModel;

  MqttSettingsUpdated(this.settingsModel);

  @override
  List<Object> get props => [settingsModel];
}

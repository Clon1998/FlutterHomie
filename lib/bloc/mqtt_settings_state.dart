import 'package:equatable/equatable.dart';
import 'package:flutter_homie/data/model/settings_model.dart';
import 'package:flutter_homie/homie/stat/stat_model.dart';

abstract class MqttSettingsState extends Equatable {
  const MqttSettingsState();

  @override
  List<Object> get props => [];
}

class MqttSettingsInitial extends MqttSettingsState {}

class MqttSettingsCurrent extends MqttSettingsState {
  final SettingsModel settingsModel;

  MqttSettingsCurrent(this.settingsModel);

  @override
  List<Object> get props => [settingsModel];
}

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_homie/data/model/settings_model.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'mqtt_setting.dart';

class MqttSettingsBloc extends HydratedBloc<MqttSettingsEvent, MqttSettingsState> {
  @override
  MqttSettingsState get initialState => super.initialState ?? MqttSettingsState.initial();

  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  @override
  Stream<MqttSettingsState> mapEventToState(
    MqttSettingsEvent event,
  ) async* {
    if (event is MqttSettingsEventRetrieved) yield MqttSettingsState.available(event.settingsModel);
  }

  @override
  MqttSettingsState fromJson(Map<String, dynamic> json) {
    try {
      if (json.isNotEmpty) {
        return MqttSettingsState.available(SettingsModel.fromJson(Map<String, dynamic>.from(json['settingsModel'])));
      }
      return null;
    } catch (_) {
      //ToDo: Actually do sth. useful with the Exception
      print('Errr $_');
      return null;
    }
  }

  @override
  Map<String, dynamic> toJson(MqttSettingsState state) {
    try {
      return state.maybeWhen(
          orElse: () => null,
          available: (SettingsModel model) {
            var map = {'settingsModel': model.toJson()};
            return map;
          });
    } catch (_) {
      //ToDo: Actually do sth. useful with the Exception
      return null;
    }
  }
}

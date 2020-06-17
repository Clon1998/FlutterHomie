import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_homie/data/model/settings_model.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import './bloc.dart';

class MqttSettingsBloc extends HydratedBloc<MqttSettingsEvent, MqttSettingsState> {

  @override
  MqttSettingsState get initialState => super.initialState ?? MqttSettingsInitial();

  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  @override
  Stream<MqttSettingsState> mapEventToState(
    MqttSettingsEvent event,
  ) async* {
    if (event is MqttSettingsUpdated) {
      yield MqttSettingsCurrent(event.settingsModel);
    }
  }

  @override
  MqttSettingsState fromJson(Map<String, dynamic> json) {
    try {
      if (json.isNotEmpty) {
        return MqttSettingsCurrent(SettingsModel.fromJson(Map<String, dynamic>.from(json['settingsModel'])));
      }
      return null;
    } catch (_) {
      print('Errr $_');
      return null;
    }
  }

  @override
  Map<String, dynamic> toJson(MqttSettingsState state) {
    try {
      if (state is MqttSettingsCurrent) {
        var map = {'settingsModel': state.settingsModel.toJson()};
        return map;
      } else
        return null;
    } catch (_) {
      return null;
    }
  }
}

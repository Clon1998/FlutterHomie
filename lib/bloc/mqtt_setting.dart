import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_homie/data/model/settings_model.dart';
import 'package:flutter_homie/exception/homie_exception.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

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
}


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

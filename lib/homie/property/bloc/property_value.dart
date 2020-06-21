import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_homie/data/homie_data_provider.dart';
import 'package:flutter_homie/data/mqtt_data_provider.dart';
import 'package:flutter_homie/dependency_injection.dart';
import 'package:flutter_homie/exception/homie_exception.dart';
import 'package:flutter_homie/homie/property/property_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'property_value.freezed.dart';

@freezed
abstract class PropertyValueState with _$PropertyValueState {
  const factory PropertyValueState.initial() = PropertyValueStateInitial;

  const factory PropertyValueState.loading() = PropertyValueStateLoading;

  const factory PropertyValueState.failure(HomieException exception) = PropertyValueStateFailure;

  const factory PropertyValueState.cmd() = PropertyValueStateCmd;

  const factory PropertyValueState.current(String value, String setValue) = PropertyValueStateCurrent;
}

@freezed
abstract class PropertyValueEvent with _$PropertyValueEvent {
  const factory PropertyValueEvent.opened(PropertyModel propertyModel) = PropertyValueEventOpened;

  const factory PropertyValueEvent.valueChanged(String value) = PropertyValueEventValueChanged;

  const factory PropertyValueEvent.setChanged(String setValue) = PropertyValueEventSetChanged;

  const factory PropertyValueEvent.updated({PropertyModel model, String cmd}) = PropertyValueEventUpdated;
}

class PropertyValueBloc extends Bloc<PropertyValueEvent, PropertyValueState> {
  final HomieDataProvider _mqttDataProvider;
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  PropertyValueBloc([HomieDataProvider mqttDataProvider]) : _mqttDataProvider = mqttDataProvider ?? getIt<MqttDataProvider>();

  String _expected = '0';
  String _actual = '0';

  StreamSubscription<String> valueStreamSub;
  StreamSubscription<String> setStreamSub;

  @override
  PropertyValueState get initialState => PropertyValueState.initial();

  @override
  Stream<PropertyValueState> mapEventToState(
    PropertyValueEvent event,
  ) async* {
    yield* event.maybeWhen(
        orElse: () async* {},
        opened: (propertyModel) async* {
          yield PropertyValueState.loading();
          try {
            Stream<String> valueStream;
            if (propertyModel.currentValue != null) {
              valueStream = propertyModel.currentValue;
            } else if (propertyModel.retained) {
              valueStream = (await _mqttDataProvider.getPropertyValue(
                      propertyModel.deviceId, propertyModel.nodeId, propertyModel.propertyId))
                  .fold((HomieException exception) {
                throw exception;
              }, (value) => value);
            }
            if (valueStream != null) {
              valueStreamSub?.cancel();

              valueStreamSub = valueStream.listen((val) {
                add(PropertyValueEvent.valueChanged(val));
              });
            }

            Stream<String> setStream;
            if (propertyModel.expectedValue != null) {
              setStream = propertyModel.expectedValue;
            } else if (propertyModel.settable) {
              setStream = (await _mqttDataProvider.getPropertyValue(
                      propertyModel.deviceId, propertyModel.nodeId, propertyModel.propertyId, true))
                  .fold((HomieException exception) {
                throw exception;
              }, (value) => value);
            }

            if (setStream != null) {
              setStreamSub?.cancel();

              setStreamSub = setStream.listen((setVal) {
                add(PropertyValueEvent.setChanged(setVal));
              });
            }
          } on HomieException catch (e) {
            yield PropertyValueState.failure(e);
          }
        },
        valueChanged: (value) async* {
          _actual = value;
          yield PropertyValueState.current(_actual, _expected);
        },
        setChanged: (setValue) async* {
          _expected = setValue;
          yield PropertyValueState.current(_actual, _expected);
        },
        updated: (model, cmd) async* {
          print('Update request: $cmd');
          yield PropertyValueState.cmd();
          _mqttDataProvider.setPropertyValue(value: cmd, propertyModel: model);
        });
  }

  @override
  Future<void> close() async {
    //ToDo: Is await required/bad/good here or not???
    await valueStreamSub?.cancel();
    await setStreamSub?.cancel();
    return super.close();
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_homie/bloc/bloc.dart';
import 'package:flutter_homie/data/mqtt_data_provider.dart';
import 'package:flutter_homie/dependency_injection.dart';
import 'package:flutter_homie/exception/homie_exception.dart';
import 'package:flutter_homie/homie/property/property_model.dart';
import 'package:flutter_homie/homie/property/property_validation_error.dart';

import './bloc.dart';

class PropertyValueBloc extends Bloc<PropertyValueEvent, PropertyValueState> {
  final MqttDataProvider _mqttDataProvider;
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  PropertyValueBloc([MqttDataProvider mqttDataProvider]) : _mqttDataProvider = mqttDataProvider ?? getIt<MqttDataProvider>();

  String _expected = '0';
  String _actual = '0';

  StreamSubscription<String> valueStreamSub;
  StreamSubscription<String> setStreamSub;

  @override
  PropertyValueState get initialState => PropertyValueInitial();

  @override
  Stream<PropertyValueState> mapEventToState(
    PropertyValueEvent event,
  ) async* {
    if (event is PropertyValueOpened) {
      yield PropertyValueLoading();
      Stream<String> valueStream;
      if (event.propertyModel.currentValue != null) {
        valueStream = event.propertyModel.currentValue;
      } else if (event.propertyModel.retained) {
        valueStream = await _mqttDataProvider.getPropertyValue(
            event.propertyModel.deviceId, event.propertyModel.nodeId, event.propertyModel.propertyId);
      }
      if (valueStream != null) {
        valueStreamSub?.cancel();

        valueStreamSub = valueStream.listen((val) {
          add(PropertyValueChanged(val));
        });
      }

      Stream<String> setStream;
      if (event.propertyModel.expectedValue != null) {
        setStream = event.propertyModel.expectedValue;
      } else if (event.propertyModel.settable) {
        setStream = await _mqttDataProvider.getPropertyValue(
            event.propertyModel.deviceId, event.propertyModel.nodeId, event.propertyModel.propertyId, true);
      }

      if (setStream != null) {
        setStreamSub?.cancel();

        setStreamSub = setStream.listen((setVal) {
          add(PropertySetValueChanged(setVal));
        });
      }
    }

    if (event is PropertyValueChanged) {
      _actual = event.value;
      yield PropertyValueCurrent(_actual, _expected);
    }

    if (event is PropertySetValueChanged) {
      _expected = event.setValue;
      yield PropertyValueCurrent(_actual, _expected);
    }

    if (event is PropertyValueUpdated) {
      yield PropertyValueUpdateRequest();

      print('Update request: ${event.newValue}');

      _mqttDataProvider.setPropertyValue(value: event.newValue, propertyModel: event.propertyModel);

    }
  }


  @override
  Future<void> close() async {
    //ToDo: Is await required/bad/good here or not???
    await valueStreamSub?.cancel();
    await setStreamSub?.cancel();
    return super.close();
  }
}

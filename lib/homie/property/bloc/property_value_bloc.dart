import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_homie/bloc/bloc.dart';
import 'package:flutter_homie/data/mqtt_data_provider.dart';
import 'package:flutter_homie/dependency_injection.dart';
import 'package:flutter_homie/exception/homie_exception.dart';
import 'package:flutter_homie/homie/property/property_model.dart';
import 'package:flutter_homie/homie/property/property_validation_error.dart';

import './bloc.dart';

class PropertyValueBloc extends Bloc<PropertyValueEvent, PropertyValueState> {
  PropertyValueBloc([MqttDataProvider mqttDataProvider]) : _mqttDataProvider = mqttDataProvider ?? getIt<MqttDataProvider>();
  final MqttDataProvider _mqttDataProvider;

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
      event.validationDialogBloc?.add(ValidationDialogValidationRequested());
      yield PropertyValueUpdateRequest();

      print('Update request: ${event.newValue}');
      //ToDo: Value Validation with DataType + format
      var validationError = validateValue(event.propertyModel, event.newValue);
      if (validationError == null) {
        _mqttDataProvider.setPropertyValue(value: event.newValue, propertyModel: event.propertyModel);
        event.validationDialogBloc?.add(ValidationDialogValidationSuccess());
      } else {
        event.validationDialogBloc?.add(ValidationDialogValidationFailed(validationError));
      }
    }
  }

  PropertyValidationError validateValue(PropertyModel propertyModel, String value) {
    if (value == null) return PropertyValidationError.empty;
    switch (propertyModel.datatype) {
      case PropertyDataType.integer:
        if (value.isEmpty) return PropertyValidationError.empty;
        var num = int.tryParse(value);
        if (num == null) return PropertyValidationError.notNumeric;
        Either<HomieException, String> format = propertyModel.format;

        PropertyValidationError error = format?.fold((l) => null, (format){
          var borders = format?.split(':');
          if (borders != null && borders.length == 2) {
            var min = int.tryParse(borders[0]);
            var max = int.tryParse(borders[1]);

            if (min != null && num < min) return PropertyValidationError.toSmall;
            if (max != null && num > max) return PropertyValidationError.toBig;
          }
          return null;
        });
        if (error != null)
          return error;
        break;
      case PropertyDataType.float:
        if (value.isEmpty) return PropertyValidationError.empty;
        var num = double.tryParse(value);
        if (num == null) return PropertyValidationError.notFloating;
        Either<HomieException, String> format = propertyModel.format;

        PropertyValidationError error = format?.fold((HomieException e) => throw e, (format){
          var borders = format?.split(':');
          if (borders != null && borders.length == 2) {
            var min = double.tryParse(borders[0]);
            var max = double.tryParse(borders[1]);

            if (min != null && num < min) return PropertyValidationError.toSmall;
            if (max != null && num > max) return PropertyValidationError.toBig;
          }
          return null;
        });
        if (error != null)
          return error;

        break;
      case PropertyDataType.boolean:
        if (!['true', 'false'].contains(value)) return PropertyValidationError.noBool;
        break;
      case PropertyDataType.string:
        if (value.length > 0x10000000)
          return PropertyValidationError.sizeExceeded; //String types are limited to 268,435,456 characters - Homie Impl
        break;
      case PropertyDataType.enumeration:
        return PropertyValidationError.general;
        break;
      case PropertyDataType.color:
        if (propertyModel.format == null) return PropertyValidationError.general;
        var isRGB = propertyModel.format.fold((HomieException e) => throw e, (val) => val == 'rgb');
        var triple = value.split(',').map(int.tryParse);
        if (triple.length != 3) return PropertyValidationError.general;
        if (isRGB) {
          if (triple.where((element) => element > 255).isNotEmpty) return PropertyValidationError.wrongRGBFormat;
        } else {
          var hsvTriple = triple.toList();
          if (hsvTriple[0] > 360 || hsvTriple[1] > 100 || hsvTriple[2] > 100) return PropertyValidationError.wrongHSVFormat;
        }

        break;
    }
    return null;
  }

  @override
  Future<void> close() async {
    //ToDo: Is await required/bad/good here or not???
    await valueStreamSub?.cancel();
    await setStreamSub?.cancel();
    return super.close();
  }
}

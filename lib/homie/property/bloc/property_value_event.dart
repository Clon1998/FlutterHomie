import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_homie/bloc/bloc.dart';
import 'package:flutter_homie/homie/property/property_model.dart';

abstract class PropertyValueEvent extends Equatable {
  const PropertyValueEvent();
}

class PropertyValueOpened extends PropertyValueEvent {

  final PropertyModel propertyModel;

  PropertyValueOpened({@required this.propertyModel});

  @override
  List<Object> get props => [propertyModel];
}

class PropertyValueChanged extends PropertyValueEvent {
  final String value;

  PropertyValueChanged(this.value);

  @override
  List<Object> get props => [value];
}

class PropertySetValueChanged extends PropertyValueEvent {
  final String setValue;

  PropertySetValueChanged(this.setValue);

  @override
  List<Object> get props => [setValue];
}

//Updated by user
class PropertyValueUpdated extends PropertyValueEvent {
  final PropertyModel propertyModel;
  final String newValue;

  PropertyValueUpdated(
      {
      @required this.propertyModel,
      @required this.newValue});

  @override
  List<Object> get props => [newValue, propertyModel];
}

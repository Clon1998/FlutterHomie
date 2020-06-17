import 'package:equatable/equatable.dart';

abstract class PropertyValueState extends Equatable {
  const PropertyValueState();

  @override
  List<Object> get props => [];
}

class PropertyValueInitial extends PropertyValueState {}

class PropertyValueLoading extends PropertyValueState {}

class PropertyValueCurrent extends PropertyValueState {
  final String value;
  final String setValue;

  PropertyValueCurrent(this.value, this.setValue);

  @override
  List<Object> get props => [value, setValue];
}

class PropertyValueUpdateRequest extends PropertyValueState {}

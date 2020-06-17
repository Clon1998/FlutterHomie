import 'package:equatable/equatable.dart';

abstract class PropertyOptionalAttributeState extends Equatable {
  const PropertyOptionalAttributeState();

  @override
  List<Object> get props => [];
}

class PropertyOptionalAttributeInitial extends PropertyOptionalAttributeState {}
class PropertyOptionalAttributeNotFound extends PropertyOptionalAttributeState {}

class PropertyOptionalAttributeFound extends PropertyOptionalAttributeState {
  final String attValue;

  PropertyOptionalAttributeFound(this.attValue);

  @override
  List<Object> get props => [attValue];
}

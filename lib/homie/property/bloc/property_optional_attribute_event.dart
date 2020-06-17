import 'package:equatable/equatable.dart';

abstract class PropertyOptionalAttributeEvent extends Equatable {
  const PropertyOptionalAttributeEvent();
}

class PropertyOptionalAttributeRequested extends PropertyOptionalAttributeEvent {
  final Future<String> future;

  PropertyOptionalAttributeRequested(this.future);

  @override
  List<Object> get props => [future];
}
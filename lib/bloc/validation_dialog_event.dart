import 'package:equatable/equatable.dart';
import 'package:flutter_homie/homie/property/property_validation_error.dart';

abstract class ValidationDialogEvent extends Equatable {
  const ValidationDialogEvent();

  @override
  List<Object> get props => [];
}

class ValidationDialogValidationReset extends ValidationDialogEvent {}
class ValidationDialogValueChanged extends ValidationDialogEvent {
  final String val;

  ValidationDialogValueChanged([this.val]);

  @override
  List<Object> get props => [val];
}


class ValidationDialogValidationFailed extends ValidationDialogEvent {
  final PropertyValidationError error;

  ValidationDialogValidationFailed(this.error);

  @override
  List<Object> get props => [error];
}

class ValidationDialogValidationSuccess extends ValidationDialogEvent {}

class ValidationDialogValidationRequested extends ValidationDialogEvent {}

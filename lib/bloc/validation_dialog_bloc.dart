import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_homie/bloc/bloc.dart';
import 'package:flutter_homie/homie/property/property_validation_error.dart';

class ValidationDialogBloc extends Bloc<ValidationDialogEvent, ValidationDialogState> {
  @override
  ValidationDialogState get initialState => ValidationDialogIdle();

  @override
  Stream<ValidationDialogState> mapEventToState(
    ValidationDialogEvent event,
  ) async* {
    if (event is ValidationDialogValidationReset) yield ValidationDialogIdle();
    if (event is ValidationDialogValueChanged) yield ValidationDialogIdle(event.val);
    if (event is ValidationDialogValidationRequested) yield ValidationDialogBusy();
    if (event is ValidationDialogValidationSuccess) yield ValidationDialogSuccess();
    if (event is ValidationDialogValidationFailed) yield ValidationDialogError(event.error.description);
  }
}

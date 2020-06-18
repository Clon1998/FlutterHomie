import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_homie/bloc/bloc.dart';
import 'package:flutter_homie/homie/property/property_validation_error.dart';

class ValidationDialogBloc extends Bloc<ValidationDialogEvent, ValidationDialogState> {

  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

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

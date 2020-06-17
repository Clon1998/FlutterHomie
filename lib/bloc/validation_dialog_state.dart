import 'package:equatable/equatable.dart';
import 'package:progress_state_button/progress_button.dart';

abstract class ValidationDialogState extends Equatable {
  const ValidationDialogState();

  ButtonState get toButtonState;

  @override
  List<Object> get props => [];
}

class ValidationDialogIdle extends ValidationDialogState {
  final String val;

  ValidationDialogIdle([this.val]);
  @override
  ButtonState get toButtonState => ButtonState.idle;

  @override
  List<Object> get props => [val];
}

class ValidationDialogBusy extends ValidationDialogState {
  @override
  ButtonState get toButtonState => ButtonState.loading;
}

class ValidationDialogError extends ValidationDialogState {
  final String reason;

  ValidationDialogError(this.reason);

  @override
  ButtonState get toButtonState => ButtonState.fail;

  @override
  List<Object> get props => [reason];
}

class ValidationDialogSuccess extends ValidationDialogState {
  @override
  ButtonState get toButtonState => ButtonState.success;
}

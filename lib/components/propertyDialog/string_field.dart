import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/bloc/bloc.dart';
import 'package:flutter_homie/homie/property/property_model.dart';

class StringField extends StatelessWidget {
  final PropertyModel propertyModel;
  final TextEditingController _textInput;

  const StringField({
    Key key,
    @required this.propertyModel,
    @required TextEditingController textInput,
  })  : _textInput = textInput,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ValidationDialogBloc, ValidationDialogState>(
      builder: (context, validationState) {
        return TextField(
          decoration: InputDecoration(
              labelText: "Enter a value for ${propertyModel.name}",
              errorText: (validationState is ValidationDialogError) ? validationState.reason : null),
          controller: _textInput,
          onChanged: (text) {
            if (validationState is ValidationDialogError)
              BlocProvider.of<ValidationDialogBloc>(context).add(ValidationDialogValidationReset());
          },
        );
      },
    );
  }
}

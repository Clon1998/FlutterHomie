import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/bloc/bloc.dart';
import 'package:flutter_homie/homie/property/property_model.dart';

class BooleanField extends StatelessWidget {
  const BooleanField({
    Key key,
    @required this.propertyModel,
    @required TextEditingController numberInput,
  })  : _numberInput = numberInput,
        super(key: key);

  final PropertyModel propertyModel;
  final TextEditingController _numberInput;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ValidationDialogBloc, ValidationDialogState>(builder: (context, validationState) {
      return SwitchListTile(
        title: Text('Change bool Property'),
        value: (_numberInput.text == 'true'),
        onChanged: (v) {
          //ToDo: Rebuild of this Widget is missing/fked up
          _numberInput.text = v ? 'true' : 'false';
          BlocProvider.of<ValidationDialogBloc>(context).add(ValidationDialogValueChanged(_numberInput.text));
        },
      );
    });
  }
}

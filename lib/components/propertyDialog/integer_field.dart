import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/bloc/bloc.dart';
import 'package:flutter_homie/homie/property/property_model.dart';

class IntegerField extends StatelessWidget {
  const IntegerField({
    Key key,
    @required this.propertyModel,
    @required TextEditingController numberInput,
  })  : _numberInput = numberInput,
        super(key: key);

  final PropertyModel propertyModel;
  final TextEditingController _numberInput;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ValidationDialogBloc, ValidationDialogState>(
      builder: (context, validationState) {
        if (propertyModel.format != null) {
          var formatBorders = propertyModel.format.split(':').map((e) => double.tryParse(e)).toList();
          var divs = (formatBorders[1]-formatBorders[0]).round();
          return Slider(
            divisions: divs,
            label: _numberInput.text,
            value: double.tryParse(_numberInput.text)??formatBorders[0],
            min: formatBorders[0],
            max: formatBorders[1],
            onChanged: (val) {
              BlocProvider.of<ValidationDialogBloc>(context).add(ValidationDialogValueChanged(val.round().toString()));
              _numberInput.text = val.round().toString();
            },
          );
        }

        return TextField(
          decoration: InputDecoration(
              labelText: "Enter a value for ${propertyModel.name}",
              errorText: (validationState is ValidationDialogError) ? validationState.reason : null),
          controller: _numberInput,
          onChanged: (text) {
            if (validationState is ValidationDialogError)
              BlocProvider.of<ValidationDialogBloc>(context).add(ValidationDialogValidationReset());
          },
          keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
        );
      },
    );
  }
}

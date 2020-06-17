import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/bloc/bloc.dart';
import 'package:flutter_homie/homie/property/property_model.dart';

class FloatField extends StatelessWidget {
  const FloatField({
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
      if (propertyModel.format != null) {
        var formatBorders = propertyModel.format.split(':').map((e) => double.tryParse(e)).toList();
        var divs = (formatBorders[1]-formatBorders[0]).round();
        if (divs == 1){
          divs = 100;
        }
        return Slider(
          divisions: divs,
          label: _numberInput.text,
          value: double.tryParse(_numberInput.text)??formatBorders[0],
          min: formatBorders[0],
          max: formatBorders[1],
          onChanged: (val) {
            BlocProvider.of<ValidationDialogBloc>(context).add(ValidationDialogValueChanged(val.toStringAsFixed(2)));
            _numberInput.text = val.toStringAsFixed(2);
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
    });
  }
}

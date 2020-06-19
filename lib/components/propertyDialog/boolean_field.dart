import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
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
    bool currentValue = propertyModel.currentValue.hasValue ? propertyModel.currentValue.value == 'true' : false;

    return FormBuilderSwitch(
      initialValue: currentValue,
      attribute: 'newValue',
      label: Text('Bool-Value'),
      decoration: InputDecoration(border: const UnderlineInputBorder(), contentPadding: EdgeInsets.all(12.0), labelText: 'Value'),
      valueTransformer: (v) => v? 'true':'false',
    );
  }
}

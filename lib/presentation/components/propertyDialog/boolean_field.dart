import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_homie/homie/property/property_model.dart';

class BooleanField extends StatelessWidget {
  const BooleanField({
    Key key,
    @required this.propertyModel,
    @required TextEditingController numberInput,
  }) : super(key: key);

  final PropertyModel propertyModel;

  @override
  Widget build(BuildContext context) {
    bool currentValue = propertyModel.currentValue.hasValue ? propertyModel.currentValue.value == 'true' : false;

    return FormBuilderSwitch(
      initialValue: currentValue,
      attribute: 'newValue',
      label: Text('Bool-Value'),
      decoration: InputDecoration(border: const UnderlineInputBorder(), contentPadding: EdgeInsets.all(12.0), labelText: 'Value'),
      valueTransformer: (v) => v ? 'true' : 'false',
    );
  }
}

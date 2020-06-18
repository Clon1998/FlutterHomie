import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_homie/bloc/bloc.dart';
import 'package:flutter_homie/homie/property/property_model.dart';

class StringField extends StatelessWidget {
  final PropertyModel propertyModel;

  const StringField({
    Key key,
    @required this.propertyModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      initialValue: propertyModel.currentValue.hasValue ? propertyModel.currentValue.value : '',
      attribute: 'newValue',
      decoration: InputDecoration(border: const UnderlineInputBorder(), contentPadding: EdgeInsets.all(12.0), labelText: 'Value'),
      keyboardType: TextInputType.text,
      validators: [
        FormBuilderValidators.required(),
      ],
      autocorrect: false,
      maxLines: 1,
    );
  }
}

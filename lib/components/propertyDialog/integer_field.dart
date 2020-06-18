import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_homie/exception/homie_exception.dart';
import 'package:flutter_homie/homie/property/property_model.dart';

class IntegerField extends StatelessWidget {
  const IntegerField({
    Key key,
    @required this.propertyModel,
  }) : super(key: key);

  final PropertyModel propertyModel;

  @override
  Widget build(BuildContext context) {
    var formatBorders = propertyModel.format.fold((HomieException e) => throw e, (r) => r.split(':').map((e) => double.tryParse(e)).toList());
    num lowerBorder = formatBorders[0]??0;
    num upperBorder = formatBorders[1]??1000;
    num currentValue = propertyModel.currentValue.hasValue? double.tryParse(propertyModel.currentValue.value)??lowerBorder:lowerBorder;
    return FormBuilderTouchSpin(
      max: upperBorder,
      min: lowerBorder,
      initialValue: currentValue,
      step: 1,
      attribute: 'newValue',
    );
  }
}

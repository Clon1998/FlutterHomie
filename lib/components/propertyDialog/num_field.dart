import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_homie/exception/homie_exception.dart';
import 'package:flutter_homie/homie/property/property_model.dart';
import 'package:intl/intl.dart';

class NumField extends StatelessWidget {
  const NumField({
    Key key,
    @required this.propertyModel,
  }) : super(key: key);

  final PropertyModel propertyModel;

  @override
  Widget build(BuildContext context) {
    num currentValue = propertyModel.currentValue.hasValue ? double.tryParse(propertyModel.currentValue.value) : 0;
    num lowerBorder = 0;
    num upperBorder = 9999;
    num stepSize;
    NumberFormat format = NumberFormat.decimalPattern();
    //ToDo: extract this Business Logic
    if (propertyModel.format != null) {
      var formatBorders =
          propertyModel.format.fold((HomieException e) => throw e, (r) => r.split(':').map((e) => double.tryParse(e)).toList());
      lowerBorder = formatBorders[0] ?? 0;
      upperBorder = formatBorders[1] ?? 1000;
      if (currentValue < lowerBorder) currentValue = lowerBorder;
      if (currentValue > upperBorder) currentValue = upperBorder;
      stepSize = (upperBorder - lowerBorder <= 1) ? 0.1 : 1;
    }

    return FormBuilderTouchSpin(
      max: upperBorder,
      min: lowerBorder,
      initialValue: currentValue,
      step: stepSize ?? 1,
      attribute: 'newValue',
      displayFormat: format,
      decoration: InputDecoration(border: const UnderlineInputBorder(), contentPadding: EdgeInsets.all(12.0), labelText: 'Value'),
      valueTransformer: (v) => (propertyModel.datatype == PropertyDataType.float)? v.toStringAsFixed(2):v.round().toString(),
    );
  }
}

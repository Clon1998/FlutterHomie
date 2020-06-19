import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_homie/bloc/bloc.dart';
import 'package:flutter_homie/components/propertyDialog/string_field.dart';
import 'package:flutter_homie/exception/homie_exception.dart';
import 'package:flutter_homie/homie/property/property_model.dart';

class ColorField extends StatelessWidget {
  const ColorField({
    Key key,
    @required this.propertyModel,
    @required TextEditingController numberInput,
  })  : _numberInput = numberInput,
        super(key: key);

  final PropertyModel propertyModel;
  final TextEditingController _numberInput;

  @override
  Widget build(BuildContext context) {
    if (propertyModel.format == null ||
        !['hsv', 'rgb'].contains(propertyModel.format.fold((HomieException e) => throw e, (f) => f)))
      return StringField(propertyModel: propertyModel);

    var isRGB = propertyModel.format.fold((HomieException e) => throw e, (val) => val == 'rgb');
    Color currentColor = Color(0xFFFFFFFF);
    if (propertyModel.currentValue.hasValue) {
      var colorTriple = propertyModel.currentValue.value.split(',');
      if (colorTriple.length == 3) {
        if (isRGB) {
          var r = int.tryParse(colorTriple[0]) ?? 0;
          var g = int.tryParse(colorTriple[1]) ?? 0;
          var b = int.tryParse(colorTriple[2]) ?? 0;
          currentColor = Color.fromRGBO(r, g, b, 1);
        } else {
          var hue = double.tryParse(colorTriple[0]) ?? 0;
          var saturation = double.tryParse(colorTriple[1]) / 100 ?? 0;
          var value = double.tryParse(colorTriple[2]) / 100 ?? 0;
          currentColor = HSVColor.fromAHSV(1, hue, saturation, value).toColor();
        }
      }
    }
    return FormBuilderColorPicker(
      initialValue: currentColor,
      cursorColor: currentColor,
      attribute: 'newValue',
      colorPickerType: ColorPickerType.MaterialPicker,
      decoration: InputDecoration(border: const UnderlineInputBorder(), contentPadding: EdgeInsets.all(12.0), labelText: 'Value'),
      valueTransformer: (v) {
        if (isRGB) {
          return '${v.red},${v.green},${v.blue}';
        } else {
          var hsvColor = HSVColor.fromColor(v);
          return '${hsvColor.hue.round()},${(hsvColor.saturation * 100).round()},${(hsvColor.value * 100).round()}';
        }
      },
    );
  }
}

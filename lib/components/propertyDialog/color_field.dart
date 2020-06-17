import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_homie/bloc/bloc.dart';
import 'package:flutter_homie/components/propertyDialog/string_field.dart';
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
    if (propertyModel.format == null || !['hsv', 'rgb'].contains(propertyModel.format))
      return StringField(propertyModel: propertyModel, textInput: _numberInput);

    return BlocBuilder<ValidationDialogBloc, ValidationDialogState>(
      builder: (context, validationState) {
        var isRGB = propertyModel.format == 'rgb';
        Color pickerColor = Color(0xFFFFFFFF);
        if (propertyModel.currentValue.hasValue) {
          var colorTriple = propertyModel.currentValue.value.split(',');
          if (colorTriple.length == 3) {
            if (isRGB) {
              var r = int.tryParse(colorTriple[0]) ?? 0;
              var g = int.tryParse(colorTriple[1]) ?? 0;
              var b = int.tryParse(colorTriple[2]) ?? 0;
              pickerColor = Color.fromRGBO(r, g, b, 1);
            } else {
              var hue = double.tryParse(colorTriple[0]) ?? 0;
              var saturation = double.tryParse(colorTriple[1]) / 100 ?? 0;
              var value = double.tryParse(colorTriple[2]) / 100 ?? 0;
              pickerColor = HSVColor.fromAHSV(1, hue, saturation, value).toColor();
            }
          }
        }

        return SingleChildScrollView(
          child: SlidePicker(
            paletteType: isRGB ? PaletteType.rgb : PaletteType.hsv,
            enableAlpha: false,
            showIndicator: true,
            pickerColor: pickerColor,
            showLabel: false,
            onColorChanged: (value) {
              if (isRGB) {
                _numberInput.text = '${value.red},${value.green},${value.blue}';
              } else {
                var hsvColor = HSVColor.fromColor(value);
                _numberInput.text =
                    '${hsvColor.hue.round()},${(hsvColor.saturation * 100).round()},${(hsvColor.value * 100).round()}';
              }
            },
//          showLabel: true,
//          pickerAreaHeightPercent: 0.8,
          ),
        );
      },
    );
  }
}

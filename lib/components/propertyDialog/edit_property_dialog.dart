import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_homie/components/propertyDialog/boolean_field.dart';
import 'package:flutter_homie/components/propertyDialog/color_field.dart';
import 'package:flutter_homie/components/propertyDialog/const.dart';
import 'package:flutter_homie/components/propertyDialog/num_field.dart';
import 'package:flutter_homie/components/propertyDialog/string_field.dart';
import 'package:flutter_homie/homie/property/bloc/property_value.dart';
import 'package:flutter_homie/homie/property/property_model.dart';

class EditPropertyDialog extends StatelessWidget {
  final PropertyModel propertyModel;
  final PropertyValueBloc propertyValueBloc;

  const EditPropertyDialog({Key key, this.propertyModel, this.propertyValueBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _textInput =
        TextEditingController(text: propertyModel.currentValue.hasValue ? propertyModel.currentValue.value : null);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: Consts.padding,
              bottom: Consts.padding,
              left: Consts.padding,
              right: Consts.padding,
            ),
            margin: EdgeInsets.only(top: Consts.avatarRadius),
            decoration: new BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(Consts.padding),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: FormBuilder(
              autovalidate: true,
              key: propertyValueBloc.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min, // To make the card compact
                children: <Widget>[
                  Text(
                    'Edit Property "${propertyModel.name}"',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  dataTypeField(_textInput, propertyModel),
                  SizedBox(height: 24.0),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: FlatButton(
                        onPressed: () {
                          var _fbKey = propertyValueBloc.formKey;
                          if (_fbKey.currentState.saveAndValidate()) {
                            propertyValueBloc.add(
                                PropertyValueEvent.updated(model: propertyModel, cmd: _fbKey.currentState.value['newValue']));
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text('Submit'),
                      )),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget dataTypeField(TextEditingController _textInput, PropertyModel propertyModel) {
    switch (propertyModel.datatype) {
      case PropertyDataType.integer:
      case PropertyDataType.float:
        return NumField(propertyModel: propertyModel);

      case PropertyDataType.color:
        return ColorField(propertyModel: propertyModel, numberInput: _textInput);

      case PropertyDataType.boolean:
        return BooleanField(propertyModel: propertyModel, numberInput: _textInput);

      case PropertyDataType.string:
      default:
        return StringField(propertyModel: propertyModel);
    }
  }
}

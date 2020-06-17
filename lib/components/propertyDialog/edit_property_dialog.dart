import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/bloc/bloc.dart';
import 'package:flutter_homie/components/propertyDialog/boolean_field.dart';
import 'package:flutter_homie/components/propertyDialog/color_field.dart';
import 'package:flutter_homie/components/propertyDialog/const.dart';
import 'package:flutter_homie/components/propertyDialog/float_field.dart';
import 'package:flutter_homie/components/propertyDialog/integer_field.dart';
import 'package:flutter_homie/components/propertyDialog/string_field.dart';
import 'package:flutter_homie/homie/property/bloc/bloc.dart';
import 'package:flutter_homie/homie/property/property_model.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

class EditPropertyDialog extends StatelessWidget {
  final PropertyModel propertyModel;
  final PropertyValueBloc propertyValueBloc;

  const EditPropertyDialog({Key key, this.propertyModel, this.propertyValueBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _textInput =
        TextEditingController(text: propertyModel.currentValue.hasValue ? propertyModel.currentValue.value : null);

    return BlocProvider<ValidationDialogBloc>(
      create: (context) => ValidationDialogBloc(),
      child: Dialog(
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
                    child: BlocConsumer<ValidationDialogBloc, ValidationDialogState>(listener: (context, validationState) {
                      if (validationState is ValidationDialogSuccess) {
                        Navigator.of(context).pop(); // To close the dialog
                      }
                    }, builder: (context, validationState) {
                      return ProgressButton.icon(
                        iconedButtons: {
                          ButtonState.idle: IconedButton(
                              text: "Set-Value", icon: Icon(Icons.send, color: Colors.white), color: Colors.deepPurple.shade500),
                          ButtonState.loading: IconedButton(text: "Loading", color: Colors.deepPurple.shade700),
                          ButtonState.fail: IconedButton(
                              text: "Failed", icon: Icon(Icons.cancel, color: Colors.white), color: Colors.red.shade300),
                          ButtonState.success: IconedButton(
                              text: "Success",
                              icon: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              color: Colors.green.shade400)
                        },
                        state: validationState.toButtonState,
                        onPressed: () {
                          if (validationState is ValidationDialogIdle)
                            propertyValueBloc.add(PropertyValueUpdated(
                                validationDialogBloc: BlocProvider.of<ValidationDialogBloc>(context),
                                propertyModel: propertyModel,
                                newValue: _textInput.text));
                          if (validationState is ValidationDialogError) Navigator.of(context).pop();
                        },
                      );
                    }),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget dataTypeField(TextEditingController _textInput, PropertyModel propertyModel) {
    switch (propertyModel.datatype) {
      case PropertyDataType.integer:
        return IntegerField(propertyModel: propertyModel, numberInput: _textInput);

      case PropertyDataType.color:
        return ColorField(propertyModel: propertyModel, numberInput: _textInput);

      case PropertyDataType.float:
        return FloatField(propertyModel: propertyModel, numberInput: _textInput);

      case PropertyDataType.boolean:
        return BooleanField(propertyModel: propertyModel, numberInput: _textInput);

      case PropertyDataType.string:
      default:
        return StringField(propertyModel: propertyModel, textInput: _textInput);
    }
  }
}

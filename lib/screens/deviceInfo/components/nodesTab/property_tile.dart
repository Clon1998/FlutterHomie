import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/components/propertyDialog/edit_property_dialog.dart';
import 'package:flutter_homie/components/snack_bar_helpers.dart';
import 'package:flutter_homie/exception/homie_exception.dart';
import 'package:flutter_homie/homie/device/device_discover_model.dart';
import 'package:flutter_homie/homie/property/bloc/property_optional_attribute_bloc.dart';
import 'package:flutter_homie/homie/property/bloc/property_value.dart';
import 'package:flutter_homie/homie/property/property_datatype_extension.dart';
import 'package:flutter_homie/homie/property/property_model.dart';
import 'package:progress_indicators/progress_indicators.dart';

class PropertyTile extends StatelessWidget {
  const PropertyTile({
    Key key,
    @required this.propertyModel,
  }) : super(key: key);

  final PropertyModel propertyModel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PropertyValueBloc>(
      create: (BuildContext context) =>
      PropertyValueBloc()
        ..add(PropertyValueEvent.opened(propertyModel)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 10.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Theme
                  .of(context)
                  .primaryColorDark, width: 5.0, style: BorderStyle.solid),
            ),
            color: Colors.white,
//            boxShadow: [
//              BoxShadow(
//                color: Colors.black,
//                blurRadius: 8.0,
//                spreadRadius: -6.0,
//                offset: Offset(0, 0), // shadow direction: bottom right
//              )
//            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 9.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '${propertyModel.name}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16.0,
                            ),
                          ),
                          buildChips(propertyModel)
                        ],
                      ),
                      BlocConsumer<PropertyValueBloc, PropertyValueState>(
                        listenWhen: (previous, current) {
                          return current is PropertyValueStateCurrent && previous is PropertyValueStateCmd;
                        },
                        listener: (context, state) {
                          state.maybeWhen(
                              orElse: () => {},
                              current: (String value, String setValue) =>
                                  SnackBarHelpers.showSuccessSnackBar(
                                      context, 'Send command to property ${propertyModel.name} with value: "$setValue"'),
                              failure: (HomieException e) =>
                                  SnackBarHelpers.showErrorSnackBar(context, e.toString(), title: 'Error sending Command')
                          );
                        },
                        buildWhen: (previous, current) => !(current is PropertyValueStateCmd),
                        builder: (context, valueState) {
                          return valueState.maybeWhen(
                              orElse: () => Container(),
                              loading: () => FadingText('Value is beeing fetched...'),
                              current: (value, setValue) {
                                List<Widget> list = List();
                                if (propertyModel.retained) list.add(Text('Value: $value'));

                                if (propertyModel.settable) list.add(Text('Set-Value: $setValue'));

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: list,
                                );
                              });
                        },
                      ),
                      Text(
                        'Topic: ${DeviceDiscoverModel.deviceDiscoveryTopic}/${propertyModel.deviceId}/${propertyModel
                            .nodeId}/${propertyModel.propertyId}/+',
                        style: const TextStyle(fontSize: 12.0),
                      ),
                      Text(
                        'ID: ${propertyModel.propertyId}',
                        style: const TextStyle(fontSize: 12.0),
                      ),
                      Text(
                        'Datatype: ${propertyModel.datatype.displayName}',
                        style: const TextStyle(fontSize: 12.0),
                      ),
                      BlocProvider<PropertyOptionalAttributeBloc>(
                        create: (context) =>
                        PropertyOptionalAttributeBloc()
                          ..add(PropertyOptionalAttributeEvent.requested(propertyModel.unitFuture)),
                        child: BlocBuilder<PropertyOptionalAttributeBloc, PropertyOptionalAttributeState>(
                          builder: (context, attState) {
                            return attState.maybeWhen(
                                orElse: () => Container(),
                                found: (attributeValue) => Text('Unit: $attributeValue', style: const TextStyle(fontSize: 12.0)));
                          },
                        ),
                      ),
                      BlocProvider<PropertyOptionalAttributeBloc>(
                        create: (context) =>
                        PropertyOptionalAttributeBloc()
                          ..add(PropertyOptionalAttributeEvent.requested(propertyModel.formatFuture)),
                        child: BlocBuilder<PropertyOptionalAttributeBloc, PropertyOptionalAttributeState>(
                          builder: (context, attState) {
                            return attState.maybeWhen(
                                orElse: () => Container(),
                                found: (attributeValue) =>
                                    Text('Format: $attributeValue', style: const TextStyle(fontSize: 12.0)));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: propertyModel.settable
                        ? () {
                      //ToDo: I dont think i need to close this Bloc here since it comes from the Context/BlocProvider
                      PropertyValueBloc propertyValueBloc = BlocProvider.of<PropertyValueBloc>(context);
                      showDialog(
                          context: context,
                          builder: (context) {
                            return EditPropertyDialog(propertyModel: propertyModel, propertyValueBloc: propertyValueBloc);
                          });
                    }
                        : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row buildChips(PropertyModel propertyModel) {
    List<Widget> chipList = List();
    if (propertyModel.retained) {
      chipList.add(Chip(
        backgroundColor: Colors.lime,
        label: Text('Retained', style: const TextStyle(fontSize: 12.0)),
        elevation: 2,
      ));
      chipList.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.0),
      ));
    }

    if (propertyModel.settable) {
      chipList
          .add(Chip(backgroundColor: Colors.cyan, label: Text('Settable', style: const TextStyle(fontSize: 12.0)), elevation: 2));
    }

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, mainAxisSize: MainAxisSize.min, children: chipList);
  }
}

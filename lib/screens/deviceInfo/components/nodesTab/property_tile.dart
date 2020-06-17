import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/components/propertyDialog/edit_property_dialog.dart';
import 'package:flutter_homie/components/snack_bar_helpers.dart';
import 'package:flutter_homie/homie/device/device_discover_model.dart';
import 'package:flutter_homie/homie/property/bloc/bloc.dart';
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
      create: (BuildContext context) => PropertyValueBloc()..add(PropertyValueOpened(propertyModel: propertyModel)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 10.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Theme.of(context).primaryColorDark, width: 5.0, style: BorderStyle.solid),
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
                          return previous is PropertyValueUpdateRequest && current is PropertyValueCurrent;
                        },
                        listener: (context, state) {
                          if (state is PropertyValueCurrent) {
                            SnackBarHelpers.showSuccessSnackBar(context, 'Send command to property ${propertyModel.name} with value: "${state.setValue}"');

                          }
                        },
                        buildWhen: (previous, current) {
                          return !(current is PropertyValueUpdateRequest);
                        },
                        builder: (context, valueState) {
                          if (valueState is PropertyValueLoading) return FadingText('Value is beeing fetched...');

                          if (valueState is PropertyValueCurrent) {
                            List<Widget> list = List();
                            if (propertyModel.retained) list.add(Text('Value: ${valueState.value}'));

                            if (propertyModel.settable) list.add(Text('Set-Value: ${valueState.setValue}'));

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: list,
                            );
                          }
                          return Text('TO BE IMPLEMENTED');
                        },
                      ),
                      Text(
                        'Topic: ${DeviceDiscoverModel.deviceDiscoveryTopic}/${propertyModel.deviceId}/${propertyModel.nodeId}/${propertyModel.propertyId}/+',
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
                            PropertyOptionalAttributeBloc()..add(PropertyOptionalAttributeRequested(propertyModel.unitFuture)),
                        child: BlocBuilder<PropertyOptionalAttributeBloc, PropertyOptionalAttributeState>(
                          builder: (context, attState) {
                            if (attState is PropertyOptionalAttributeFound) {
                              return Text('Unit: ${attState.attValue}', style: const TextStyle(fontSize: 12.0));
                            }

                            return Container();
                          },
                        ),
                      ),
                      BlocProvider<PropertyOptionalAttributeBloc>(
                        create: (context) =>
                            PropertyOptionalAttributeBloc()..add(PropertyOptionalAttributeRequested(propertyModel.formatFuture)),
                        child: BlocBuilder<PropertyOptionalAttributeBloc, PropertyOptionalAttributeState>(
                          builder: (context, attState) {
                            if (attState is PropertyOptionalAttributeFound) {
                              return Text('Format: ${attState.attValue}', style: const TextStyle(fontSize: 12.0));
                            }

                            return Container();
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
                            PropertyValueBloc propertyValueBloc = BlocProvider.of<PropertyValueBloc>(context);
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return EditPropertyDialog(
                                      propertyModel: propertyModel, propertyValueBloc: propertyValueBloc);
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

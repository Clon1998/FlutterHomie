import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/homie/device/bloc/bloc.dart';
import 'package:flutter_homie/homie/device/device_discover_model.dart';
import 'package:flutter_homie/homie/device/device_state_extension.dart';

class DeviceMetaInfoTab extends StatelessWidget {
  DeviceMetaInfoTab();

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        BlocBuilder<DeviceInfoBloc, DeviceInfoState>(
          builder: (context, deviceBlocState) {
            return deviceBlocState.maybeWhen(
                orElse: () => Container(),
                result: (deviceModel, deviceState) => Card(
                        child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Table(
                        children: [
                          TableRow(children: [Text('Name'), Text('${deviceModel.name}')]),
                          TableRow(children: [
                            Text('State'),
                            Chip(
                              label: Text('${deviceState.toName}'),
                              backgroundColor: deviceState.toColor,
                            ),
                          ]),
                          TableRow(children: [
                            Text('Topic'),
                            Text('${DeviceDiscoverModel.deviceDiscoveryTopic}/${deviceModel.deviceId}/+')
                          ]),
                          TableRow(children: [Text('Homie Version'), Text('${deviceModel.homie}')]),
                          TableRow(children: [Text('MAC'), Text('${deviceModel.mac}')]),
                          TableRow(children: [Text('Local Ip'), Text('${deviceModel.localIp}')]),
//                  TableRow(children: [Text('Nodes'), Text('${state.deviceModel.nodes}')]),
                        ],
                      ),
                    )));
          },
        )
      ],
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/homie/device/device_discover_model.dart';
import 'package:flutter_homie/homie/stat/bloc/bloc.dart';


//ToDo: Replace this with only StatValue Bloc! So StatModel is loaded in advance
class StatInfoWidget extends StatelessWidget {
  final String statId;
  final String deviceId;

  const StatInfoWidget({Key key, this.statId, this.deviceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StatInfoBloc>(
        create: (context) => StatInfoBloc()..add(StateInfoOpened(statId: statId, deviceId: deviceId)),
        child: BlocBuilder<StatInfoBloc, StatInfoState>(
          builder: (context, state) {
            if (state is StatInfoLoading) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                ],
              );
            }

            if (state is StatInfoResult) {
              return Column(
                children: <Widget>[
                  Card(
                      elevation: 3.0,
                      child: ListTile(
                        isThreeLine: true,
                        title: Text('$statId'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text('${DeviceDiscoverModel.deviceDiscoveryTopic}/$deviceId/\$stats/$statId'),
                            Text(
                              'Value: ${state.statModel.value}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )),
                ],
              );
            }
            return Container();
          },
        ));
  }
}

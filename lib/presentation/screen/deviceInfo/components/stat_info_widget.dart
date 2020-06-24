import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/presentation/components/snack_bar_helpers.dart';
import 'package:flutter_homie/exception/homie_exception.dart';
import 'package:flutter_homie/homie/device/device_discover_model.dart';
import 'package:flutter_homie/homie/stat/bloc/stat_info_bloc.dart';

//ToDo: Replace this with only StatValue Bloc! So StatModel is loaded in advance
class StatInfoWidget extends StatelessWidget {
  final String statId;
  final String deviceId;

  const StatInfoWidget({Key key, this.statId, this.deviceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StatInfoBloc>(
        create: (context) => StatInfoBloc()..add(StatInfoEvent.opened(statId: statId, deviceId: deviceId)),
        child: BlocConsumer<StatInfoBloc, StatInfoState>(
          listener: (context, state) {
            state.maybeWhen(
                orElse: () => {},
                failure: (HomieException e) =>
                    SnackBarHelpers.showErrorSnackBar(context, e.toString(), title: 'Error Loading Stats'));
          },
          builder: (context, state) {
            return state.maybeWhen(
                orElse: () => Container(),
                loading: () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                      ],
                    ),
                result: (statModel) => Column(
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
                                    'Value: ${statModel.value}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ));
          },
        ));
  }
}

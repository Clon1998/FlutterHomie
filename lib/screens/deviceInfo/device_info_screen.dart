import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/components/snack_bar_helpers.dart';
import 'package:flutter_homie/exception/homie_exception.dart';
import 'package:flutter_homie/homie/device/bloc/bloc.dart';
import 'package:flutter_homie/homie/device/bloc/device_info.dart';
import 'package:flutter_homie/homie/device/device_discover_model.dart';
import 'package:flutter_homie/screens/deviceInfo/components/device_stats_list_tab.dart';
import 'package:flutter_homie/screens/deviceInfo/components/nodesTab/device_nodes_list_tab.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'components/device_meta_info_tab.dart';

class DeviceInfoScreen extends StatelessWidget {
  //ToDo: Instead use GetIt to make this a singleton
  final DeviceDiscoverModel deviceDiscoverModel;
  final DeviceConnectionStateBloc deviceStateBloc;

  DeviceInfoScreen({this.deviceDiscoverModel, this.deviceStateBloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeviceInfoBloc>(
      create: (context) => DeviceInfoBloc(deviceStateBloc)..add(DeviceInfoEvent.opened(deviceDiscoverModel.deviceId)),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              title: Text('Device ${deviceDiscoverModel.name} Info'),
              bottom: TabBar(
                tabs: <Widget>[
                  Tab(text: 'Meta Info'),
                  Tab(text: 'Nodes'),
                  Tab(text: 'Stats'),
                ],
              ),
            ),
            body: BlocConsumer<DeviceInfoBloc, DeviceInfoState>(listener: (context, state) {
              state.maybeWhen(
                  orElse: () => {},
                  failure: (HomieException e) =>
                      SnackBarHelpers.showErrorSnackBar(context, e.toString(), title: 'Error loading Device Info'));
            }, builder: (context, state) {
              return state.maybeWhen(
                  orElse: () => TabBarView(
                        children: <Widget>[
                          DeviceMetaInfoTab(),
                          DeviceNodesListTab(),
                          DeviceStatsListTab(),
                        ],
                      ),
                  loading: () => Center(child: Padding(
                      padding: EdgeInsets.all(90),
                      child: LoadingIndicator(indicatorType: Indicator.ballScaleMultiple,)))
              );
            })),
      ),
    );
  }
}

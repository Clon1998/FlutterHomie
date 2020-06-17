import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/homie/device/bloc/bloc.dart';
import 'package:flutter_homie/screens/deviceInfo/components/stat_info_widget.dart';

class DeviceStatsListTab extends StatelessWidget {
  DeviceStatsListTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceInfoBloc, DeviceInfoState>(
      builder: (context, deviceBlocState) {
        if (deviceBlocState is DeviceInfoLoading) {
          return Column(children: [Container(child: LinearProgressIndicator())]);
        }
        if (deviceBlocState is DeviceInfoResult) {
          return Container(
            child: ListView.builder(
              itemCount: deviceBlocState.deviceModel.stats.length,
              itemBuilder: (context, index) {
                return StatInfoWidget(
                  statId: deviceBlocState.deviceModel.stats[index],
                  deviceId: deviceBlocState.deviceModel.deviceId,
                );
              },
            ),
          );
        }
        return Container();
      },
    );
  }
}

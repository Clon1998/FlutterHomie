import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/homie/device/bloc/bloc.dart';
import 'package:flutter_homie/presentation/screen/deviceInfo/components/stat_info_widget.dart';

class DeviceStatsListTab extends StatelessWidget {
  DeviceStatsListTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceInfoBloc, DeviceInfoState>(
      builder: (context, deviceBlocState) {
        return deviceBlocState.maybeWhen(
            orElse: () => Container(),
            result: (deviceModel, deviceState) => Container(
                  child: ListView.builder(
                    itemCount: deviceModel.stats.length,
                    itemBuilder: (context, index) {
                      return StatInfoWidget(
                        statId: deviceModel.stats[index],
                        deviceId: deviceModel.deviceId,
                      );
                    },
                  ),
                ));
      },
    );
  }
}

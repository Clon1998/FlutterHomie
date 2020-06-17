import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/components/silver_keep_alive.dart';
import 'package:flutter_homie/homie/device/bloc/bloc.dart';
import 'package:flutter_homie/screens/deviceInfo/components/nodesTab/node_card.dart';

class DeviceNodesListTab extends StatelessWidget {
  DeviceNodesListTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceInfoBloc, DeviceInfoState>(
      builder: (context, deviceBlocState) {
        if (deviceBlocState is DeviceInfoLoading) {
          return Column(children: [Container(child: LinearProgressIndicator())]);
        }
        if (deviceBlocState is DeviceInfoResult) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return SilverWrapper(
                    child: NodeCard(
                      nodeModel: deviceBlocState.deviceModel.nodeModels[index],
                    ),
                  );
                }, childCount: deviceBlocState.deviceModel.nodes.length),
              )
            ],
          );
        }
        return Container();
      },
    );
  }
}

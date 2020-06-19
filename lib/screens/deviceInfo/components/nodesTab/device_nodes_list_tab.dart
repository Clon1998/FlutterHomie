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
        return deviceBlocState.maybeWhen(
            orElse: () => Container(),
            loading: () => Column(children: [Container(child: LinearProgressIndicator())]),
            result: (deviceModel, deviceState) => CustomScrollView(
                  slivers: <Widget>[
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return SilverWrapper(
                          child: NodeCard(
                            nodeModel: deviceModel.nodeModels[index],
                          ),
                        );
                      }, childCount: deviceModel.nodes.length),
                    )
                  ],
                ));
      },
    );
  }
}

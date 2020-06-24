import 'package:flutter/material.dart';
import 'package:flutter_homie/homie/device/device_discover_model.dart';
import 'package:flutter_homie/homie/node/node_model.dart';
import 'package:flutter_homie/presentation/screen/deviceInfo/components/nodesTab/property_tile.dart';

class NodeCard extends StatelessWidget {
  const NodeCard({
    Key key,
    @required this.nodeModel,
  }) : super(key: key);

  final NodeModel nodeModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      child: ExpansionTile(
        title: Text('${nodeModel.name}'),
        subtitle: Text('${DeviceDiscoverModel.deviceDiscoveryTopic}/${nodeModel.deviceId}/${nodeModel.nodeId}/+'),
        children: <Widget>[
          Text('NodeID: ${nodeModel.nodeId}'),
          Text('Type: ${nodeModel.type}'),
          Divider(color: Colors.black),
          Text(
            'Properties',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.left,
          ),
          Divider(color: Colors.black),
          Column(
            children: nodeModel.propertyModels
                .map((propertyModel) => PropertyTile(propertyModel: propertyModel))
                .toList(),
          )
        ],
      ),
    );
  }
}

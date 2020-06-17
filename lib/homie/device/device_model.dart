import 'package:equatable/equatable.dart';
import 'package:flutter_homie/homie/node/node_model.dart';

enum HomieDeviceState { init, ready, disconnected, sleeping, lost, alert }

class DeviceModel extends Equatable {
  final String deviceId;
  final String name;
  final List<String> nodes;
  final List<NodeModel> nodeModels;
  final List<String> stats;
//  final List<String> stats;
  final String homie;
  final String mac;
  final String localIp;

  DeviceModel({this.deviceId, this.name, this.nodes, this.nodeModels, this.homie, this.mac, this.localIp, this.stats});

  @override
  List<Object> get props => [deviceId, name, nodes, nodeModels, homie, mac, localIp, stats];
}
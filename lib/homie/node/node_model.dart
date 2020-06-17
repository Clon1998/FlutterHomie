import 'package:equatable/equatable.dart';
import 'package:flutter_homie/homie/property/property_model.dart';

class NodeModel extends Equatable {
  final String deviceId;
  final String nodeId;
  final String name;
  final String type;
  final List<String> properties;
  final List<PropertyModel> propertyModels;

  NodeModel({this.deviceId,this.nodeId, this.name, this.type, this.properties, this.propertyModels});

  @override
  List<Object> get props => [deviceId,nodeId, name, type, properties, propertyModels];
}

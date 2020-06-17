import 'package:equatable/equatable.dart';

class SettingsModel extends Equatable {
  final String mqttIp;
  final int mqttPort;
  final String mqttClientId;

  SettingsModel({this.mqttIp, this.mqttPort, this.mqttClientId});

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(mqttIp: json['baseUrl'], mqttPort: json['port'], mqttClientId: json['clientID']??'AndoirApp');
  }

  Map<String, dynamic> toJson() {

    return {'baseUrl': mqttIp , 'port': mqttPort, 'clientID': mqttClientId};
  }

  @override
  List<Object> get props => [mqttIp, mqttPort, mqttClientId];
}

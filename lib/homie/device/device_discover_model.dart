import 'package:equatable/equatable.dart';
import 'package:mqtt_client/mqtt_client.dart';

class DeviceDiscoverModel extends Equatable {
  final String deviceId;
  final String name;

  //ToDo: Instead of a hardcoded one, use a Settings Bloc that defines this shit!
  static String deviceDiscoveryTopic = 'homie';

  DeviceDiscoverModel({this.deviceId, this.name});

  static DeviceDiscoverModel fromMqtt(MqttReceivedMessage msg) {
    final MqttPublishMessage recMess = msg.payload;
    String topic = msg.topic;
    var split = topic.split("/");
    var deviceId = split.length > 2 ? split[1] : topic;

    final name = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    return DeviceDiscoverModel(name: name, deviceId: deviceId);
  }

  @override
  List<Object> get props => [deviceId, name];
}

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_homie/data/model/settings_model.dart';
import 'package:flutter_homie/exception/homie_exception.dart';
import 'package:flutter_homie/homie/device/device_discover_model.dart';
import 'package:flutter_homie/homie/device/device_model.dart';
import 'package:flutter_homie/homie/node/node_model.dart';
import 'package:flutter_homie/homie/property/property_datatype_extension.dart';
import 'package:flutter_homie/homie/property/property_model.dart';
import 'package:flutter_homie/homie/stat/stat_model.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:rxdart/rxdart.dart';

class _Helper<T> {
  final Subject<T> subject;
  final MqttClientTopicFilter topicFilter;

  _Helper(this.subject, this.topicFilter);
}

class MqttDataProvider {
  MqttServerClient client;
  Future<MqttClientConnectionStatus> mqttClientConnectionStatus;
  MqttClientTopicFilter discoveryTopicFilter;
  Map<String, BehaviorSubject<dynamic>> dynamicSubMap = Map();
  Map<String, MqttClientTopicFilter> dynamicFilterMap = Map();

  Map<String, _Helper> helperMaps = Map();

  MqttDataProvider();

  void checkConnection() {
    if (client == null) {
      throw HomieException.mqttNotFound(client);
    }
    if (client.connectionStatus.state != MqttConnectionState.connected) {
      throw HomieException.mqttConnectionError(client.connectionStatus.state);
    }
  }

  Future<Stream<DeviceDiscoverModel>> getDiscoveryResult() async {
    checkConnection();
    String key = 'discovery';

    _Helper<DeviceDiscoverModel> helps = helperMaps.putIfAbsent(key, () {
      _Helper<DeviceDiscoverModel> h = _Helper(ReplaySubject<DeviceDiscoverModel>(),
          MqttClientTopicFilter('${DeviceDiscoverModel.deviceDiscoveryTopic}/+/\$name', client.updates));
      h.subject.addStream(h.topicFilter.updates.map((event) => event[0]).map(DeviceDiscoverModel.fromMqtt));
      client.subscribe(h.topicFilter.topic, MqttQos.atMostOnce);
      return h;
    });

    return helps.subject.stream;
  }

  Future<String> getDeviceAttribute(String deviceId, String attribute) async {
    checkConnection();

    String key = '$deviceId-$attribute';
    //ToDo::: close_sinks
    // ignore: close_sinks
    BehaviorSubject<String> attributeSubject = dynamicSubMap.putIfAbsent(key, () {
      var subject = BehaviorSubject<String>();
      var filter = dynamicFilterMap.putIfAbsent(
          key, () => MqttClientTopicFilter('${DeviceDiscoverModel.deviceDiscoveryTopic}/$deviceId/$attribute', client.updates));
      subject.addStream(filter.updates.map(_mqttPacketToPayload));
      client.subscribe(filter.topic, MqttQos.atMostOnce);
      return subject;
    });
    if (attributeSubject.hasValue)
      return attributeSubject.value;
    else
      return attributeSubject.first;
  }

  Future<Stream<String>> getDynamicDeviceAttribute(String deviceId, String attribute) async {
    checkConnection();

    String key = '$deviceId-$attribute';
    //ToDo::: close_sinks
    // ignore: close_sinks
    BehaviorSubject<String> attributeStream = dynamicSubMap.putIfAbsent(key, () {
      var subject = BehaviorSubject<String>();
      var filter = dynamicFilterMap.putIfAbsent(
          key, () => MqttClientTopicFilter('${DeviceDiscoverModel.deviceDiscoveryTopic}/$deviceId/$attribute', client.updates));
      subject.addStream(filter.updates.map(_mqttPacketToPayload));
      client.subscribe(filter.topic, MqttQos.atMostOnce);
      return subject;
    });

    return attributeStream.stream;
  }

  Future<String> getNodeAttribute(String deviceId, String nodeId, String attribute) async {
    return await getDeviceAttribute(deviceId, '$nodeId/$attribute');
  }

  Future<String> getPropertyAttribute(String deviceId, String nodeId, String propertyId, String attribute) async {
    return await getNodeAttribute(deviceId, nodeId, '$propertyId/$attribute');
  }

  Future<BehaviorSubject<String>> getPropertyValue(String deviceId, String nodeId, String propertyId,
      [bool isSetTopic = false]) async {
    checkConnection();
    String key = '$deviceId-$nodeId-$propertyId${isSetTopic ? '-avalue' : '-evalue'}'; //Actual Value, Expected Value
    //ToDo::: close_sinks
    // ignore: close_sinks
    BehaviorSubject<String> attributeSubject = dynamicSubMap.putIfAbsent(key, () {
      var subject = BehaviorSubject<String>();
      var filter = dynamicFilterMap.putIfAbsent(
          key,
          () => MqttClientTopicFilter(
              '${DeviceDiscoverModel.deviceDiscoveryTopic}/$deviceId/$nodeId/$propertyId${isSetTopic ? '/set' : ''}',
              client.updates));
      subject.addStream(filter.updates.map(_mqttPacketToPayload));
      client.subscribe(filter.topic, MqttQos.atMostOnce);
      return subject;
    });

    return attributeSubject;
  }

  Future<Stream<StatModel>> getDeviceStatValue(String deviceId, String statId) async {
    checkConnection();
    String key = '$deviceId-stats-$statId';
    //ToDo::: close_sinks
    // ignore: close_sinks
    BehaviorSubject<String> attributeStream = dynamicSubMap.putIfAbsent(key, () {
      var subject = BehaviorSubject<String>();
      var filter = dynamicFilterMap.putIfAbsent(key,
          () => MqttClientTopicFilter('${DeviceDiscoverModel.deviceDiscoveryTopic}/$deviceId/\$stats/$statId', client.updates));
      subject.addStream(filter.updates.map(_mqttPacketToPayload));
      client.subscribe(filter.topic, MqttQos.atMostOnce);
      return subject;
    });

    return attributeStream.stream.map((val) => StatModel(statId: statId, value: val));
  }

  Future<DeviceModel> getDeviceModel(String deviceId) async {
    checkConnection();
    var nameF = getDeviceAttribute(deviceId, '\$name');
    var macF = getDeviceAttribute(deviceId, '\$mac');
    var localipF = getDeviceAttribute(deviceId, '\$localip');
    var nodesF = getDeviceAttribute(deviceId, '\$nodes');
    var statsF = getDeviceAttribute(deviceId, '\$stats');
    var homieF = getDeviceAttribute(deviceId, '\$homie');

    var nodes = (await nodesF).split(',');
    List<Future<NodeModel>> nodeModelsF = nodes.map((nodeId) {
      return getNodeModel(deviceId, nodeId);
    }).toList();

    var name = await nameF;
    var mac = await macF;
    var localip = await localipF;
    var stats = (await statsF).split(',');
    var homie = await homieF;
    List<NodeModel> nodeModels = await Future.wait(nodeModelsF);

    return DeviceModel(
        name: name,
        nodes: nodes,
        nodeModels: nodeModels,
        homie: homie,
        mac: mac,
        localIp: localip,
        deviceId: deviceId,
        stats: stats);
  }

  Future<NodeModel> getNodeModel(String deviceId, String nodeId) async {
    checkConnection();
    var nameF = getNodeAttribute(deviceId, nodeId, '\$name');
    var typeF = getNodeAttribute(deviceId, nodeId, '\$type');
    var propertiesF = getNodeAttribute(deviceId, nodeId, '\$properties');

    var properties = (await propertiesF).split(',');
    List<Future<PropertyModel>> propertyModelsF = properties.map((propertyId) {
      return getPropertyModel(deviceId, nodeId, propertyId);
    }).toList();

    var name = await nameF;
    var type = await typeF;
    List<PropertyModel> propertyModels = await Future.wait(propertyModelsF);

    return NodeModel(
        deviceId: deviceId, nodeId: nodeId, name: name, type: type, properties: properties, propertyModels: propertyModels);
  }

  Future<PropertyModel> getPropertyModel(String deviceId, String nodeId, String propertyId) async {
    checkConnection();
    //ToDO: This is horrible, to do it like this! Since some Attr are optional!
    var nameF = getPropertyAttribute(deviceId, nodeId, propertyId, '\$name');
    var datatypeF = getPropertyAttribute(deviceId, nodeId, propertyId, '\$datatype');
    var settableF = getPropertyAttribute(deviceId, nodeId, propertyId, '\$settable');
    var retainedF = getPropertyAttribute(deviceId, nodeId, propertyId, '\$retained');
    var currentValueF = getPropertyValue(deviceId, nodeId, propertyId);
    var expectedValueF = getPropertyValue(deviceId, nodeId, propertyId, true);

    Future<String> unit = getPropertyAttribute(deviceId, nodeId, propertyId, '\$unit');
    Future<String> format = getPropertyAttribute(deviceId, nodeId, propertyId, '\$format');

    var name = await nameF;
    PropertyDataType type = PropertyDataTypeDecorated.fromString(await datatypeF);
    bool settable = await settableF == 'true';
    bool retained = await retainedF == 'true';
    Stream<String> currentValue = await currentValueF;
    Stream<String> expectedValue = await expectedValueF;

    return PropertyModel(
      deviceId: deviceId,
      nodeId: nodeId,
      propertyId: propertyId,
      name: name,
      datatype: type,
      settable: settable,
      retained: retained,
      unit: unit,
      format: format,
      currentValue: currentValue,
      expectedValue: expectedValue,
    );
  }

  void setPropertyValue({String deviceId, String nodeId, String propertyId, PropertyModel propertyModel, String value}) {
    checkConnection();

    if (propertyModel == null && (deviceId.isEmpty || nodeId.isEmpty || propertyId.isEmpty)) return; //ToDo: Throw error!

    var payloadBuilder = MqttClientPayloadBuilder();
    payloadBuilder.addString(value);

    var dId = (propertyModel != null) ? propertyModel.deviceId : deviceId;
    var nId = (propertyModel != null) ? propertyModel.nodeId : nodeId;
    var pId = (propertyModel != null) ? propertyModel.propertyId : propertyId;

    client.publishMessage(
        '${DeviceDiscoverModel.deviceDiscoveryTopic}/$dId/$nId/$pId/set', MqttQos.exactlyOnce, payloadBuilder.payload);
  }

  String _mqttPacketToPayload(List<MqttReceivedMessage<MqttMessage>> mqttData) {
    //ToDo: Improve null bla
    if (mqttData == null) return 'null';
    final MqttPublishMessage recMess = mqttData[0].payload;

    return MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
  }

  Future<Either<HomieException, MqttClientConnectionStatus>> tryConnect(SettingsModel settingsModel) async {
    try {
      client = MqttServerClient.withPort(settingsModel.mqttIp, settingsModel.mqttClientId, settingsModel.mqttPort);
      _prepareConnect(settingsModel.mqttClientId);
      MqttClientConnectionStatus result = await client.connect();
      return Right(result);
    } on SocketException catch(f) {
      return Left(HomieException.mqttConnectionError(f));
    }

  }

  void _prepareConnect(String ident) {
    client.logging(on: false);

    client.keepAlivePeriod = 30;

    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(ident)
        .startClean() // Non persistent session for testing
        .keepAliveFor(30)
        .withWillQos(MqttQos.exactlyOnce);
    print('[MQTT client] MQTT client connecting....');
    client.connectionMessage = connMess;
  }

  void _onDisconnected() {
    print('[MQTT client] _onDisconnected');
    print('[MQTT client] MQTT client disconnected');
//    dynamicFilterMap.values.forEach((element) async {
//      await element.updates.drain();
//    });
//    dynamicSubMap.values.forEach((element) {
//      element?.close();
//    });
//    dynamicSubMap.clear();
//    dynamicFilterMap.clear();
//    behaviorSubject?.close();
  }

  void _onConnected() {
    print('EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }
}

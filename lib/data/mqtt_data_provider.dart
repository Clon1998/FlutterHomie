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

  List<Function> listOfCb = List();

  Map<String, _Helper> helperMaps = Map();

  MqttDataProvider();

  HomieException checkConnection() {
    if (client == null) {
      return HomieException.mqttNotFound(client);
    }
    if (client.connectionStatus.state != MqttConnectionState.connected) {
      return HomieException.mqttConnectionError(client.connectionStatus.state);
    }
    return null;
  }

  Future<Either<HomieException,Stream<DeviceDiscoverModel>>> getDiscoveryResult() async {
    HomieException cCon = checkConnection();
    if (cCon != null) {
      return Left(cCon);
    }
    String key = 'discovery';

    _Helper<DeviceDiscoverModel> helps = helperMaps.putIfAbsent(key, () {
      _Helper<DeviceDiscoverModel> h = _Helper(ReplaySubject<DeviceDiscoverModel>(),
          MqttClientTopicFilter('${DeviceDiscoverModel.deviceDiscoveryTopic}/+/\$name', client.updates));
      h.subject.addStream(h.topicFilter.updates.map((event) => event[0]).map(DeviceDiscoverModel.fromMqtt));
      client.subscribe(h.topicFilter.topic, MqttQos.atMostOnce);
      return h;
    });

    return Right(helps.subject.stream);
  }

  Future<Either<HomieException, String>> getDeviceAttribute(String deviceId, String attribute) async {
    HomieException cCon = checkConnection();
    if (cCon != null) {
      return Left(cCon);
    }

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
      return Right(attributeSubject.value);
    else
      return Right(await attributeSubject.first);
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

  Future<Either<HomieException, String>> getNodeAttribute(String deviceId, String nodeId, String attribute) {
    return getDeviceAttribute(deviceId, '$nodeId/$attribute');
  }

  Future<Either<HomieException, String>> getPropertyAttribute(
      String deviceId, String nodeId, String propertyId, String attribute) {
    return getNodeAttribute(deviceId, nodeId, '$propertyId/$attribute');
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

  Future<Either<HomieException, DeviceModel>> getDeviceModel(String deviceId) async {
    checkConnection();
    var nameF = getDeviceAttribute(deviceId, '\$name');
    var macF = getDeviceAttribute(deviceId, '\$mac');
    var localipF = getDeviceAttribute(deviceId, '\$localip');
    var nodesF = getDeviceAttribute(deviceId, '\$nodes');
    var statsF = getDeviceAttribute(deviceId, '\$stats');
    var homieF = getDeviceAttribute(deviceId, '\$homie');

    try {
      List<String> nodes = (await nodesF).fold((HomieException exception) {
        throw exception;
      }, (nodes) => nodes.split(','));

      List<Future<Either<HomieException, NodeModel>>> nodeModelsF = nodes.map((nodeId) {
        return getNodeModel(deviceId, nodeId);
      }).toList();

      var name = (await nameF).fold((HomieException exception) {
        throw exception;
      }, (value) => value);
      var mac = (await macF).fold((HomieException exception) {
        throw exception;
      }, (value) => value);
      var localip = (await localipF).fold((HomieException exception) {
        throw exception;
      }, (value) => value);
      var stats = (await statsF).fold((HomieException exception) {
        throw exception;
      }, (value) => value.split(','));
      var homie = (await homieF).fold((HomieException exception) {
        throw exception;
      }, (value) => value);

      List<NodeModel> nodeModels = (await Future.wait(nodeModelsF))
          .map((either) => either.fold((HomieException exception) => throw exception, (model) => model)).toList();
      return Right(DeviceModel(
          name: name,
          nodes: nodes,
          nodeModels: nodeModels,
          homie: homie,
          mac: mac,
          localIp: localip,
          deviceId: deviceId,
          stats: stats));
    } on HomieException catch (e) {
      return Left(e);
    }
  }

  Future<Either<HomieException, NodeModel>> getNodeModel(String deviceId, String nodeId) async {
    checkConnection();
    var nameF = getNodeAttribute(deviceId, nodeId, '\$name');
    var typeF = getNodeAttribute(deviceId, nodeId, '\$type');
    var propertiesF = getNodeAttribute(deviceId, nodeId, '\$properties');
    try {
      var properties = (await propertiesF).fold((HomieException exception) {
        throw exception;
      }, (nodes) {
        return nodes.split(',');
      });

      List<Future<Either<HomieException, PropertyModel>>> propertyModelsF = properties.map((propertyId) {
        return getPropertyModel(deviceId, nodeId, propertyId);
      }).toList();

      var name = (await nameF).fold((HomieException exception) {
        throw exception;
      }, (value) => value);
      var type = (await typeF).fold((HomieException exception) {
        throw exception;
      }, (value) => value);

      List<PropertyModel> propertyModels = (await Future.wait(propertyModelsF))
          .map((Either<HomieException, PropertyModel> either) => either.fold((HomieException exception) => throw exception, (model) => model)).toList();

      return Right(NodeModel(
          deviceId: deviceId, nodeId: nodeId, name: name, type: type, properties: properties, propertyModels: propertyModels));
    } on HomieException catch (e) {
      return Left(e);
    }
  }

  Future<Either<HomieException, PropertyModel>> getPropertyModel(String deviceId, String nodeId, String propertyId) async {
    HomieException cCon = checkConnection();
    if (cCon != null) {
      return Left(cCon);
    }

    //ToDO: This is horrible, to do it like this! Since some Attr are optional!
    var nameF = getPropertyAttribute(deviceId, nodeId, propertyId, '\$name');
    var datatypeF = getPropertyAttribute(deviceId, nodeId, propertyId, '\$datatype');
    var settableF = getPropertyAttribute(deviceId, nodeId, propertyId, '\$settable');
    var retainedF = getPropertyAttribute(deviceId, nodeId, propertyId, '\$retained');
    var currentValueF = getPropertyValue(deviceId, nodeId, propertyId);
    var expectedValueF = getPropertyValue(deviceId, nodeId, propertyId, true);

    Future<Either<HomieException, String>> unit = getPropertyAttribute(deviceId, nodeId, propertyId, '\$unit');
    Future<Either<HomieException, String>> format = getPropertyAttribute(deviceId, nodeId, propertyId, '\$format');
    try {
      var name = (await nameF).fold((HomieException exception) {
        throw exception;
      }, (value) => value);

      PropertyDataType type = (await datatypeF).fold((HomieException exception) {
        throw exception;
      }, PropertyDataTypeDecorated.fromString);

      bool settable = (await settableF).fold((HomieException exception) {
        throw exception;
      }, (value) => value == 'true');

      bool retained = (await retainedF).fold((HomieException exception) {
        throw exception;
      }, (value) => value == 'true');

      Stream<String> currentValue = await currentValueF;
      Stream<String> expectedValue = await expectedValueF;

      return Right(PropertyModel(
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
      ));
    } on HomieException catch (e) {
      return Left(e);
    }
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
    } on SocketException catch (f) {
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

    listOfCb.forEach((cb) => cb());

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

  void onDisconnect(void callback()) {
    listOfCb.add(callback);
  }

  void _onConnected() {
    print('EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }
}

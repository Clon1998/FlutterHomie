import 'package:dartz/dartz.dart';
import 'package:flutter_homie/exception/homie_exception.dart';
import 'package:flutter_homie/homie/device/device_discover_model.dart';
import 'package:flutter_homie/homie/device/device_model.dart';
import 'package:flutter_homie/homie/node/node_model.dart';
import 'package:flutter_homie/homie/property/property_model.dart';
import 'package:flutter_homie/homie/stat/stat_model.dart';
import 'package:rxdart/subjects.dart';

abstract class HomieDataProvider {
  HomieException checkConnection();

  Future<Either<HomieException, Stream<DeviceDiscoverModel>>> getDiscoveryResult();

  Future<Either<HomieException, String>> getDeviceAttribute(String deviceId, String attribute);

  Future<Stream<String>> getDeviceAttributeAsStream(String deviceId, String attribute);

  Future<Either<HomieException, String>> getNodeAttribute(String deviceId, String nodeId, String attribute);

  Future<Either<HomieException, String>> getPropertyAttribute(
      String deviceId, String nodeId, String propertyId, String attribute);

  Future<Either<HomieException, BehaviorSubject<String>>> getPropertyValue(String deviceId, String nodeId, String propertyId,
      [bool isSetTopic = false]);

  Future<Either<HomieException, Stream<StatModel>>> getDeviceStatStream(String deviceId, String statId);

  Future<Either<HomieException, DeviceModel>> getDeviceModel(String deviceId);

  Future<Either<HomieException, NodeModel>> getNodeModel(String deviceId, String nodeId);

  Future<Either<HomieException, PropertyModel>> getPropertyModel(String deviceId, String nodeId, String propertyId);

  void setPropertyValue({String deviceId, String nodeId, String propertyId, PropertyModel propertyModel, String value});
}

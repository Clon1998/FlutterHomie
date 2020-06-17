import 'package:freezed_annotation/freezed_annotation.dart';

part 'homie_exception.freezed.dart';

@freezed
abstract class HomieException with _$HomieException {
  const factory HomieException.notFound(Object error) = NotFoundHomieException;

  const factory HomieException.mqttNotFound(Object error) = MqttNotFoundHomieException;

  const factory HomieException.mqttConnectionError(Object error) =
  MqttConnectionErrorHomieException;

  const factory HomieException.emptyResponse(Object error) =
  EmptyResponseHomieException;

  const factory HomieException.malformedResponse(Object error) =
  MalformedResponseHomieException;
}
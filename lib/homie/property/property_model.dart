import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

enum PropertyDataType { integer, float, boolean, string, enumeration, color }

class PropertyModel extends Equatable {
  final String deviceId;
  final String nodeId;
  final String propertyId;
  final String name;
  final PropertyDataType datatype;
  final bool settable;
  final bool retained;
  final _Wrapper<String> _formatWrapped;
  final _Wrapper<String> _unitWrapped;
  final BehaviorSubject<String> currentValue;
  final BehaviorSubject<String> expectedValue;

  PropertyModel(
      {this.deviceId,
      this.nodeId,
      this.propertyId,
      this.name,
      this.datatype,
      this.settable,
      this.retained,
      Future<String> format,
      Future<String> unit,
      this.currentValue,
      this.expectedValue})
      : _formatWrapped = _Wrapper(format),
        _unitWrapped = _Wrapper(unit);

  String get format => _formatWrapped.latestValue;

  Future<String> get formatFuture => _formatWrapped._future;

  String get unit => _unitWrapped.latestValue;

  Future<String> get unitFuture => _unitWrapped._future;

  @override
  List<Object> get props =>
      [deviceId, nodeId, propertyId, name, datatype, settable, retained, unit, format, currentValue, expectedValue];
}

class _Wrapper<T> {
  final Future<T> _future;
  T latestValue;

  _Wrapper(this._future) {
    _future.then((value) => this.latestValue = value);
  }
}

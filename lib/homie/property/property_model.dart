import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_homie/exception/homie_exception.dart';
import 'package:rxdart/rxdart.dart';

enum PropertyDataType { integer, float, boolean, string, enumeration, color }

class PropertyModel extends Equatable {
  final String deviceId;
  final String nodeId;
  final String propertyId;
  final String name;
  final PropertyDataType datatype;
  final _Wrapper<bool> _settableWrapped;
  final _Wrapper<bool> _retainedWrapped;
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
      Future<Either<HomieException, bool>> settable,
      Future<Either<HomieException, bool>> retained,
      Future<Either<HomieException, String>> format,
      Future<Either<HomieException, String>> unit,
      this.currentValue,
      this.expectedValue})
      : _settableWrapped = _Wrapper(settable),
        _retainedWrapped = _Wrapper(retained),
        _formatWrapped = _Wrapper(format),
        _unitWrapped = _Wrapper(unit);

  bool get settable => _settableWrapped.latestValue?.fold((HomieException e) => null, (r) => r) ?? false;

  bool get retained => _retainedWrapped.latestValue?.fold((HomieException e) => null, (r) => r) ?? true;

  // ToDo: Validate that the Exception was handled somewhere earlier!
  String get format => _formatWrapped.latestValue?.fold((HomieException e) => null, (r) => r);

  Future<Either<HomieException, String>> get formatFuture => _formatWrapped._future;

  Either<HomieException, String> get unit => _unitWrapped.latestValue;

  Future<Either<HomieException, String>> get unitFuture => _unitWrapped._future;

  @override
  List<Object> get props => [
        deviceId,
        nodeId,
        propertyId,
        name,
        datatype,
        _settableWrapped,
        _retainedWrapped,
        _unitWrapped,
        _formatWrapped,
        currentValue,
        expectedValue
      ];
}

class _Wrapper<T> {
  final Future<Either<HomieException, T>> _future;
  Either<HomieException, T> latestValue;

  _Wrapper(this._future) {
    _future.then((either) => this.latestValue = either);
  }
}

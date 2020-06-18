import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_homie/exception/homie_exception.dart';

abstract class PropertyOptionalAttributeEvent extends Equatable {
  const PropertyOptionalAttributeEvent();
}

class PropertyOptionalAttributeRequested extends PropertyOptionalAttributeEvent {
  final Future<Either<HomieException, String>> future;

  PropertyOptionalAttributeRequested(this.future);

  @override
  List<Object> get props => [future];
}
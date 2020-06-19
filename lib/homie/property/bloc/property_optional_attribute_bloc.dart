import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_homie/exception/homie_exception.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'property_optional_attribute_bloc.freezed.dart';

@freezed
abstract class PropertyOptionalAttributeState with _$PropertyOptionalAttributeState {
  const factory PropertyOptionalAttributeState.initial() = PropertyOptionalAttributeStateInitial;

  const factory PropertyOptionalAttributeState.notFound() = PropertyOptionalAttributeStateNotFound;

  const factory PropertyOptionalAttributeState.found(String attributeValue) = PropertyOptionalAttributeStateFound;
}

@freezed
abstract class PropertyOptionalAttributeEvent with _$PropertyOptionalAttributeEvent {
  const factory PropertyOptionalAttributeEvent.requested(Future<Either<HomieException, String>> future) =
      PropertyOptionalAttributeEventRequested;
}

class PropertyOptionalAttributeBloc extends Bloc<PropertyOptionalAttributeEvent, PropertyOptionalAttributeState> {
  @override
  PropertyOptionalAttributeState get initialState => PropertyOptionalAttributeState.initial();

  @override
  Stream<PropertyOptionalAttributeState> mapEventToState(
    PropertyOptionalAttributeEvent event,
  ) async* {
    yield* event.maybeWhen(
        orElse: () async* {},
        requested: (future) async* {
          try {
            yield* (await event.future.timeout(Duration(seconds: 2))).fold((HomieException e) => throw e,
                (attributeValue) async* {
              yield PropertyOptionalAttributeState.found(attributeValue);
            });
          } on TimeoutException catch (e) {
            yield PropertyOptionalAttributeState.notFound();
          } on HomieException catch (e) {
            //ToDo: Do sth. with the Exception e
            print(e);
            yield PropertyOptionalAttributeState.notFound();
          }
        });
  }
}

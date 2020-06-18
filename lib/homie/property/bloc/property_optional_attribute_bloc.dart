import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_homie/exception/homie_exception.dart';

import './bloc.dart';

class PropertyOptionalAttributeBloc extends Bloc<PropertyOptionalAttributeEvent, PropertyOptionalAttributeState> {
  @override
  PropertyOptionalAttributeState get initialState => PropertyOptionalAttributeInitial();

  @override
  Stream<PropertyOptionalAttributeState> mapEventToState(
    PropertyOptionalAttributeEvent event,
  ) async* {
    if (event is PropertyOptionalAttributeRequested) {
      try {
        yield* (await event.future.timeout(Duration(seconds: 2))).fold((HomieException e) => throw e, (attributeValue) async* {
          yield PropertyOptionalAttributeFound(attributeValue);
        });
      } on TimeoutException catch (e) {
        yield PropertyOptionalAttributeNotFound();
      } on HomieException catch (e) {
        //ToDo: Do sth. with the Exception e
        print(e);
        yield PropertyOptionalAttributeNotFound();
      }
    }
  }
}

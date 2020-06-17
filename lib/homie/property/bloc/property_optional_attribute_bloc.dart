import 'dart:async';

import 'package:bloc/bloc.dart';

import './bloc.dart';

class PropertyOptionalAttributeBloc extends Bloc<PropertyOptionalAttributeEvent, PropertyOptionalAttributeState> {
  @override
  PropertyOptionalAttributeState get initialState => PropertyOptionalAttributeInitial();

  @override
  Stream<PropertyOptionalAttributeState> mapEventToState(PropertyOptionalAttributeEvent event,) async* {
    if (event is PropertyOptionalAttributeRequested) {
      try {
        String attributeValue = await event.future.timeout(Duration(seconds: 2));
            yield PropertyOptionalAttributeFound(attributeValue);
      } on TimeoutException catch (e) {
        yield PropertyOptionalAttributeNotFound();
      }
    }
  }
}

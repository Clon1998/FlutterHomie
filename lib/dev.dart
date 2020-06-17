import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SimpleBlocDelegate extends HydratedBlocDelegate {
  SimpleBlocDelegate(HydratedStorage storage) : super(storage);

  static Future<SimpleBlocDelegate> build({
    Directory storageDirectory,
    HydratedCipher encryptionCipher,
  }) async {
    return SimpleBlocDelegate(
      await HydratedBlocStorage.getInstance(
        storageDirectory: storageDirectory,
        encryptionCipher: encryptionCipher,
      ),
    );
  }


  @override
  void onEvent(Bloc bloc, Object event) {
    print(event);
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print(transition);
    super.onTransition(bloc, transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    print('$error, $stackTrace');
  }
}
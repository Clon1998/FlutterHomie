import 'package:flutter_homie/bloc/bloc.dart';
import 'package:flutter_homie/bloc/homie_connection.dart';
import 'package:get_it/get_it.dart';

import 'data/mqtt_data_provider.dart';

final getIt = GetIt.instance;


void setup() {
  getIt.registerLazySingleton<MqttDataProvider>(() => MqttDataProvider());
  getIt.registerLazySingleton<MqttSettingsBloc>(() => MqttSettingsBloc());
  getIt.registerLazySingleton<HomieConnectionBloc>(() => HomieConnectionBloc());
}

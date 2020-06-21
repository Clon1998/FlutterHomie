import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/bloc/mqtt_setting.dart';
import 'package:flutter_homie/dependency_injection.dart';
import 'package:flutter_homie/dev.dart';
import 'package:flutter_homie/screens/deviceDiscovery/device_discovery_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = await SimpleBlocDelegate.build();
  setup();
//  getIt<HomieConnectionBloc>().add(HomieConnectionEvent.ping());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: BlocProvider<MqttSettingsBloc>(
        create: (context) => getIt<MqttSettingsBloc>(),
        child: DeviceDiscoveryScreen(),
      ),
    );
  }
}

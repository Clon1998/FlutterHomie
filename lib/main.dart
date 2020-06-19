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
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<MqttSettingsBloc>(
        create: (context) => getIt<MqttSettingsBloc>(),
        child: DeviceDiscoveryScreen(),
      ),
    );
  }
}

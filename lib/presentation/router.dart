import 'package:flutter/material.dart';
import 'package:flutter_homie/presentation/screen/deviceDiscovery/device_discovery_screen.dart';
import 'package:flutter_homie/presentation/screen/deviceInfo/device_info_screen.dart';
import 'package:flutter_homie/presentation/screen/mqttSettings/mqtt_settings_screen.dart';

class Router {
  static const String DEVICE_DISCOVERY = '/device-discovery';
  static const String DEVICE_INFO = '/device-info';
  static const String SETTINGS = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case DEVICE_DISCOVERY:
        return MaterialPageRoute(builder: (_) => DeviceDiscoveryScreen());

      case SETTINGS:
        return MaterialPageRoute(builder: (_) => MqttSettingsScreen());

      case DEVICE_INFO:
        var arguments = settings.arguments as DeviceInfoScreenArguments;
        return MaterialPageRoute(
            builder: (_) => DeviceInfoScreen(
                  deviceDiscoverModel: arguments.deviceDiscoverModel,
                  deviceStateBloc: arguments.deviceStateBloc,
                ));

      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings.name}'),
                  ),
                ));
    }
  }
}

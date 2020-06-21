import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/bloc/homie_connection.dart';
import 'package:flutter_homie/bloc/mqtt_setting.dart';
import 'package:flutter_homie/components/snack_bar_helpers.dart';
import 'package:flutter_homie/dependency_injection.dart';
import 'package:flutter_homie/exception/homie_exception.dart';
import 'package:flutter_homie/homie/device/bloc/bloc.dart';
import 'package:flutter_homie/homie/device/device_discover_model.dart';
import 'package:flutter_homie/screens/mqttSettings/mqtt_settings_screen.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'components/device_grid_tile.dart';

class DeviceDiscoveryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomieConnectionBloc, HomieConnectionState>(
      bloc: getIt<HomieConnectionBloc>(),
      listener: (context, state) => state.maybeWhen(
          orElse: () => {},
          failure: (HomieException e) => SnackBarHelpers.showErrorSnackBar(context, e.toString(), title: 'Connection Error')),
      builder: (context, connectionState) {
        return BlocBuilder<MqttSettingsBloc, MqttSettingsState>(builder: (context, settingsState) {
          return BlocProvider<DiscoverDeviceBloc>(
            create: (context) => DiscoverDeviceBloc(),
            child: Scaffold(
              appBar: AppBar(
                // Here we take the value from the MyHomePage object that was created by
                // the App.build method, and use it to set our appbar title.
                title: Text('Device Discovery'),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.brightness_1,
                      size: 12,
                      color: connectionState.when(
                          disconnected: () => Colors.red,
                          initial: () => Colors.lightBlueAccent,
                          loading: () => Colors.yellow,
                          failure: (e) => Colors.red,
                          active: () => Colors.lightGreen),
                    ),
                    onPressed: () {
                      connectionState.maybeWhen(
                          orElse: () {},
                          disconnected: () {
                            var mqttSettingsState = getIt<MqttSettingsBloc>().state;
                            if (mqttSettingsState is MqttSettingsStateAvailable)
                              getIt<HomieConnectionBloc>().add(HomieConnectionEvent.open(mqttSettingsState.settingsModel));
                          },
                          failure: (e) => SnackBarHelpers.showErrorSnackBar(context, e.toString(), title: 'Connection Error'));
                    },
                    tooltip: connectionState.maybeWhen(
                        orElse: () => null,
                        initial: () => 'Connection init',
                        loading: () => 'Connection loading',
                        disconnected: () => 'Connection closed',
                        failure: (e) => 'Connection error',
                        active: () => 'Connection is active'),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MqttSettingsScreen()),
                      );
                    },
                    tooltip: 'Settings',
                  ),
                  BlocBuilder<DiscoverDeviceBloc, DeviceDiscoveryState>(builder: (context, state) {
                    return state.maybeWhen(
                        initial: () => startDiscoveryButton(connectionState, context),
                        stop: (devices) => startDiscoveryButton(connectionState, context),
                        orElse: () => stopDisoveryButton(connectionState, context));
                  }),
                ],
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    connectionState.maybeWhen(
                      orElse: () => Container(),
                      initial: () => Text('Please set MQTT Server in Settings'),
                      active: () => Text('Mqtt connection established', style: TextStyle(color: Colors.lightGreen)),
                      loading: () => Text('Trying to connect'),
                      failure: (e) => Text('Error opening Mqtt connection', style: TextStyle(color: Colors.deepOrangeAccent)),
                    ),
                    BlocBuilder<DiscoverDeviceBloc, DeviceDiscoveryState>(builder: (context, state) {
                      return state.maybeWhen(
                          orElse: () => Text('No Devices discovered yet. Please start Device disovery'),
                          active: (result) {
                            return Column(
                              children: <Widget>[
                                Text(
                                  'Device discovery running',
                                  style: TextStyle(color: Colors.lightGreen),
                                ),
                                Text(
                                  '${result.length} Devices discovered',
                                  style: Theme.of(context).textTheme.headline4,
                                )
                              ],
                            );
                          },
                          stop: (discoveryResults) {
                            return Column(
                              children: <Widget>[
                                Text(
                                  'Device discovery stopped',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                                Text(
                                  '${discoveryResults.length} Devices discovered',
                                  style: Theme.of(context).textTheme.headline4,
                                )
                              ],
                            );
                          },
                          loading: () => Text('Started Device Discovery'));
                    }),
                    Divider(color: Colors.black),
                    BlocBuilder<DiscoverDeviceBloc, DeviceDiscoveryState>(
                      builder: (context, state) {
                        return state.maybeWhen(
                          orElse: () => Text('Please start Device Discovery'),
                          loading: () => LoadingIndicator(
                            indicatorType: Indicator.pacman,
                          ),
                          active: buildGridView,
                          stop: buildGridView,
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  IconButton stopDisoveryButton(HomieConnectionState connectionState, BuildContext context) {
    return IconButton(
      icon: Icon(Icons.pause_circle_outline),
      onPressed: (connectionState is HomieConnectionStateActive)
          ? () => BlocProvider.of<DiscoverDeviceBloc>(context).add(DeviceDiscoveryEvent.stopped())
          : null,
      tooltip: 'Stop discovery',
    );
  }

  IconButton startDiscoveryButton(HomieConnectionState connectionState, BuildContext context) {
    return IconButton(
      icon: Icon(Icons.play_circle_outline),
      onPressed: (connectionState is HomieConnectionStateActive)
          ? () => BlocProvider.of<DiscoverDeviceBloc>(context).add(DeviceDiscoveryEvent.started())
          : null,
      tooltip: 'Start discovery',
    );
  }

  Expanded buildGridView(Set<DeviceDiscoverModel> devices) {
    return Expanded(
        child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 6,
            childAspectRatio: 2.5,
            children: devices.map((value) {
              return DeviceGridTile(deviceDiscoverModel: value);
            }).toList()));
  }
}

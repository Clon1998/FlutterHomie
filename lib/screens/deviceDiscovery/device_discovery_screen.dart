import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/bloc/homie_connection.dart';
import 'package:flutter_homie/bloc/mqtt_setting.dart';
import 'package:flutter_homie/bloc/mqtt_settings_bloc.dart';
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
                  Icon(
                    Icons.brightness_1,
                    size: 12,
                    color: connectionState.when(
                        disconnected: () => Colors.red,
                        initial: () => Colors.lightBlueAccent,
                        loading: () => Colors.yellow,
                        failure: (e) => Colors.red,
                        active: () => Colors.lightGreen),
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
                    if (state is DeviceDiscoveryInitial || state is DeviceDiscoveryStop) {
                      return IconButton(
                        icon: Icon(Icons.play_circle_outline),
                        onPressed: (connectionState is HomieConnectionStateActive)
                            ? () => BlocProvider.of<DiscoverDeviceBloc>(context).add(DeviceDiscoveryStarted())
                            : null,
                        tooltip: 'Starte discovery',
                      );
                    } else {
                      return IconButton(
                        icon: Icon(Icons.pause_circle_outline),
                        onPressed: (connectionState is HomieConnectionStateActive)
                            ? () => BlocProvider.of<DiscoverDeviceBloc>(context).add(DeviceDiscoveryStopped())
                            : null,
                        tooltip: 'Stoppe discovery',
                      );
                    }
                  }),
                ],
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    connectionState.maybeWhen(
                      orElse: () => Container(),
                      active: () => Text('Mqtt connection established', style: TextStyle(color: Colors.lightGreen)),
                      loading: () => Text('Trying to connect'),
                      failure: (e) => Text('Error opening Mqtt connection', style: TextStyle(color: Colors.deepOrangeAccent)),
                    ),
                    BlocBuilder<DiscoverDeviceBloc, DeviceDiscoveryState>(builder: (context, state) {
                      if (state is DeviceDiscoveryResult) {
                        return Column(
                          children: <Widget>[
                            Text(
                              'Device discovery running',
                              style: TextStyle(color: Colors.lightGreen),
                            ),
                            Text(
                              '${state.devices.length} Devices discovered',
                              style: Theme.of(context).textTheme.headline4,
                            )
                          ],
                        );
                      }
                      if (state is DeviceDiscoveryStop) {
                        return Column(
                          children: <Widget>[
                            Text(
                              'Device discovery stopped',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                            Text(
                              '${state.devices.length} Devices discovered',
                              style: Theme.of(context).textTheme.headline4,
                            )
                          ],
                        );
                      }
                      if (state is DeviceDiscoveryLoading) {
                        return Text('Started Device Discovery');
                      }
                      return Text('No Devices Discovered yet');
                    }),
                    Divider(color: Colors.black),
                    BlocBuilder<DiscoverDeviceBloc, DeviceDiscoveryState>(
                      builder: (context, state) {
                        if (state is DeviceDiscoveryInitial) {
                          return Text("Please start Device Discovery");
                        }

                        if (state is DeviceDiscoveryLoading) {
                          return LoadingIndicator(
                            indicatorType: Indicator.pacman,
                          );
                        }

                        if (state is DeviceDiscoveryResult) {
                          return buildGridView(state.devices);
                        }

                        if (state is DeviceDiscoveryStop) {
                          return buildGridView(state.devices);
                        }
                        return Text('No State found');
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

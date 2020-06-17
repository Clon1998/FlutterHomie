import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homie/homie/device/bloc/bloc.dart';
import 'package:flutter_homie/homie/device/device_discover_model.dart';
import 'package:flutter_homie/homie/device/device_state_extension.dart';
import 'package:flutter_homie/screens/deviceInfo/device_info_screen.dart';
import 'package:loading_indicator/loading_indicator.dart';


class DeviceGridTile extends StatefulWidget {
  final DeviceDiscoverModel deviceDiscoverModel;

  const DeviceGridTile({Key key, this.deviceDiscoverModel}) : super(key: key);

  @override
  _DeviceGridTileState createState() => _DeviceGridTileState();
}

class _DeviceGridTileState extends State<DeviceGridTile> {
  final DeviceStateBloc _deviceStateBloc = DeviceStateBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeviceStateBloc>.value(
      value: _deviceStateBloc..add(DeviceStateFetchingStarted(deviceId: widget.deviceDiscoverModel.deviceId)),
      child: BlocBuilder<DeviceStateBloc, DeviceStateState>(
        builder: (context, state) {
          if (state is DeviceStateInitial) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingIndicator(indicatorType: Indicator.ballTrianglePath),
              ],
            );
          }
          if (state is DeviceStateCurrent) {
            return InkResponse(
              child: Card(
                elevation: 3.0,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        width: 5.0,
                        color: state.deviceState.toColor,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('${widget.deviceDiscoverModel.name}',
                            overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${DeviceDiscoverModel.deviceDiscoveryTopic}/${widget.deviceDiscoverModel.deviceId}/+',
                            overflow: TextOverflow.ellipsis)
                      ],
                    ),
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DeviceInfoScreen(
                            deviceDiscoverModel: widget.deviceDiscoverModel,
                            deviceStateBloc: _deviceStateBloc,
                          )),
                );
              },
            );
          }
          return Container();
        },
      ),
    );
  }

  @override
  void dispose() {
    _deviceStateBloc.close();
    super.dispose();
  }
}

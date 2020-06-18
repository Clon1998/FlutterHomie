import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_homie/data/mqtt_data_provider.dart';
import 'package:flutter_homie/dependency_injection.dart';
import 'package:flutter_homie/homie/stat/stat_model.dart';

import 'bloc.dart';

class StatInfoBloc extends Bloc<StatInfoEvent, StatInfoState> {
  final MqttDataProvider _mqttDataProvider;

  StatInfoBloc([MqttDataProvider mqttDataProvider]) : _mqttDataProvider = mqttDataProvider ?? getIt<MqttDataProvider>();

  StreamSubscription<StatModel> statValueSub;

  @override
  StatInfoState get initialState => StatInfoInitial();

  @override
  Stream<StatInfoState> mapEventToState(
    StatInfoEvent event,
  ) async* {
    if (event is StateInfoOpened) {
      yield StatInfoLoading();
      Stream<StatModel> statStream = await _mqttDataProvider.getDeviceStatValue(event.deviceId, event.statId);
      statValueSub?.cancel();
      statValueSub = statStream.listen((event) {
        add(StatInfoRenewed(event));
      });
    }

    if (event is StatInfoRenewed) {
      yield StatInfoResult(event.statModel);
    }
  }

  @override
  Future<void> close() async {
    await statValueSub?.cancel();
    return super.close();
  }
}

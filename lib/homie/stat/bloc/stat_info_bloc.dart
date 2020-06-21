import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_homie/data/homie_data_provider.dart';
import 'package:flutter_homie/data/mqtt_data_provider.dart';
import 'package:flutter_homie/dependency_injection.dart';
import 'package:flutter_homie/exception/homie_exception.dart';
import 'package:flutter_homie/homie/stat/stat_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stat_info_bloc.freezed.dart';

@freezed
abstract class StatInfoState with _$StatInfoState {
  const factory StatInfoState.initial() = StatInfoStateInitial;

  const factory StatInfoState.loading() = StatInfoStateLoading;

  const factory StatInfoState.failure(HomieException e) = StatInfoStateFailure;

  const factory StatInfoState.result(StatModel statModel) = StatInfoStateResult;
}

@freezed
abstract class StatInfoEvent with _$StatInfoEvent {
  const factory StatInfoEvent.opened({String deviceId, String statId}) = StatInfoEventOpened;

  const factory StatInfoEvent.renewed(StatModel statModel) = StatInfoEventRenewed;
}

class StatInfoBloc extends Bloc<StatInfoEvent, StatInfoState> {
  final HomieDataProvider _mqttDataProvider;

  StatInfoBloc([HomieDataProvider mqttDataProvider]) : _mqttDataProvider = mqttDataProvider ?? getIt<MqttDataProvider>();

  StreamSubscription<StatModel> statValueSub;

  @override
  StatInfoState get initialState => StatInfoState.initial();

  @override
  Stream<StatInfoState> mapEventToState(
    StatInfoEvent event,
  ) async* {
    yield* event.maybeWhen(
        orElse: () async* {},
        opened: (deviceId, statId) async* {
          yield StatInfoState.loading();

          yield* (await _mqttDataProvider.getDeviceStatStream(deviceId, statId)).fold((HomieException e) async* {
            yield StatInfoState.failure(e);
          }, (statStream) async* {
            statValueSub?.cancel();
            statValueSub = statStream.listen((statModel) {
              add(StatInfoEvent.renewed(statModel));
            });
          });
        },
        renewed: (statModel) async* {
          yield StatInfoState.result(statModel);
        });
  }

  @override
  Future<void> close() async {
    await statValueSub?.cancel();
    return super.close();
  }
}

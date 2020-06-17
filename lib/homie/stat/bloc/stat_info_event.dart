import 'package:equatable/equatable.dart';
import 'package:flutter_homie/homie/stat/stat_model.dart';

abstract class StatInfoEvent extends Equatable {
  const StatInfoEvent();
  @override
  List<Object> get props => [];
}

class StateInfoOpened extends StatInfoEvent {
  final String deviceId;
  final String statId;

  StateInfoOpened({this.deviceId, this.statId});

  @override
  List<Object> get props => [deviceId, statId];
}

class StatInfoRenewed extends StatInfoEvent {
  final StatModel statModel;

  StatInfoRenewed(this.statModel);

  @override
  List<Object> get props => [statModel];
}
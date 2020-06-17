import 'package:equatable/equatable.dart';
import 'package:flutter_homie/homie/stat/stat_model.dart';

abstract class StatInfoState extends Equatable {
  const StatInfoState();

  @override
  List<Object> get props => [];
}

class StatInfoInitial extends StatInfoState {}

class StatInfoLoading extends StatInfoState {}

class StatInfoResult extends StatInfoState {
  final StatModel statModel;

  StatInfoResult(this.statModel);

  @override
  List<Object> get props => [statModel];
}

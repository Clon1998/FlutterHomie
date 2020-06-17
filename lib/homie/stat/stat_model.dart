import 'package:equatable/equatable.dart';

class StatModel extends Equatable {
  final String statId;
  final String value;

  StatModel({this.statId, this.value});

  @override
  List<Object> get props => [statId, value];
}

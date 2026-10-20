import 'package:equatable/equatable.dart';
import 'package:nic_backlog/data/models/game_log_model.dart';

sealed class GameLogState extends Equatable {
  const GameLogState();

  @override
  List<Object?> get props => [];
}

class GameLogInitial extends GameLogState {}

class GameLogLoading extends GameLogState {}

class GameLogSuccess extends GameLogState {
  final List<GameLogModel> logs;

  const GameLogSuccess(this.logs);

  @override
  List<Object?> get props => [logs];
}

class GameLogFailure extends GameLogState {
  final String errorMessage;

  const GameLogFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

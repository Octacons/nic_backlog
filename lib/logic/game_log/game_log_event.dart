import 'package:equatable/equatable.dart';
import 'package:nic_backlog/data/models/game_log_model.dart';

abstract class GameLogEvent extends Equatable {
  const GameLogEvent();

  @override
  List<Object?> get props => [];
}

class FetchGameLogsRequested extends GameLogEvent {
  final String gameId;

  const FetchGameLogsRequested({required this.gameId});

  @override
  List<Object?> get props => [gameId];
}

class AddGameLogRequested extends GameLogEvent {
  final String gameId;
  final GameLogModel log;

  const AddGameLogRequested({required this.gameId, required this.log});

  @override
  List<Object?> get props => [gameId, log];
}

class DeleteGameLogRequested extends GameLogEvent {
  final String gameId;
  final String logId;

  const DeleteGameLogRequested({required this.gameId, required this.logId});

  @override
  List<Object?> get props => [gameId, logId];
}

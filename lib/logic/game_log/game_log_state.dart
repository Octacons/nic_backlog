import 'package:equatable/equatable.dart';
import 'package:nic_backlog/data/models/game_log_model.dart';

enum GameLogStatus { initial, loading, success, failure }

class GameLogState extends Equatable {
  final GameLogStatus status;
  final List<GameLogModel> logs;
  final String? errorMessage;

  const GameLogState({
    this.status = GameLogStatus.initial,
    this.logs = const [],
    this.errorMessage,
  });

  GameLogState copyWith({
    GameLogStatus? status,
    List<GameLogModel>? logs,
    String? errorMessage,
  }) {
    return GameLogState(
      status: status ?? this.status,
      logs: logs ?? this.logs,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, logs, errorMessage];
}

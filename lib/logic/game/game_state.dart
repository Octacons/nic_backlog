import 'package:equatable/equatable.dart';
import 'package:nic_backlog/data/models/game_model.dart';

enum GameStatus { initial, loading, success, failure }

class GameState extends Equatable {
  final GameStatus status;
  final List<GameModel> games;
  final String? errorMessage;

  const GameState({
    this.status = GameStatus.initial,
    this.games = const [],
    this.errorMessage,
  });

  GameState copyWith({
    GameStatus? status,
    List<GameModel>? games,
    String? errorMessage,
  }) {
    return GameState(
      status: status ?? this.status,
      games: games ?? this.games,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, games, errorMessage];
}

import 'package:equatable/equatable.dart';
import 'package:nic_backlog/data/models/game_model.dart';

enum GameStateStatus { initial, loading, success, failure }

class GameState extends Equatable {
  final GameStateStatus status;
  final List<GameModel> games;
  final GameModel? selectedGame;
  final String? errorMessage;

  const GameState({
    this.status = GameStateStatus.initial,
    this.games = const [],
    this.selectedGame,
    this.errorMessage,
  });

  GameState copyWith({
    GameStateStatus? status,
    List<GameModel>? games,
    GameModel? selectedGame,
    String? errorMessage,
  }) {
    return GameState(
      status: status ?? this.status,
      games: games ?? this.games,
      selectedGame: selectedGame ?? this.selectedGame,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, games, selectedGame, errorMessage];
}

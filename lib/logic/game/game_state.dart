import 'package:equatable/equatable.dart';
import 'package:nic_backlog/data/models/game_model.dart';

sealed class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class GameSuccess extends GameState {
  final List<GameModel> games;
  final GameModel? selectedGame;

  const GameSuccess({
    this.games = const [],
    this.selectedGame,
  });

  @override
  List<Object?> get props => [games, selectedGame];
}

class GameFailure extends GameState {
  final String errorMessage;

  const GameFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

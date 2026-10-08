import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:nic_backlog/data/models/game_model.dart';
import 'package:nic_backlog/data/models/gamelog_model.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class AddGameRequested extends GameEvent {
  final GameModel game;
  final File? imageFile;
  const AddGameRequested({required this.game, this.imageFile});

  @override
  List<Object?> get props => [game, imageFile];
}

class FetchGamesRequested extends GameEvent {
  const FetchGamesRequested();
}

class FetchGameDetailRequested extends GameEvent {
  final String gameId;

  const FetchGameDetailRequested({required this.gameId});

  @override
  List<Object?> get props => [gameId];
}

class AddGameLogRequested extends GameEvent {
  final String gameId;
  final GameLogModel log;

  const AddGameLogRequested({required this.gameId, required this.log});

  @override
  List<Object?> get props => [gameId, log];
}

class UpdateGameRequested extends GameEvent {
  final GameModel game;
  final File? imageFile;

  const UpdateGameRequested({required this.game, this.imageFile});

  @override
  List<Object?> get props => [game, imageFile];
}

import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:nic_backlog/data/models/game_model.dart';

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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nic_backlog/data/repositories/game_repository.dart';
import 'package:nic_backlog/logic/game/game_event.dart';
import 'package:nic_backlog/logic/game/game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GameRepository gameRepository;

  GameBloc({required this.gameRepository}) : super(const GameState()) {
    on<AddGameRequested>(_onAddGameRequested);
  }

  Future<void> _onAddGameRequested(
    AddGameRequested event,
    Emitter<GameState> emit,
  ) async {
    emit(state.copyWith(status: GameStatus.loading));

    try {
      await gameRepository.addGame(event.game);
      emit(state.copyWith(status: GameStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: GameStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}

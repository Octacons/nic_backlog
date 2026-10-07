import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nic_backlog/data/models/game_model.dart';
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
    emit(state.copyWith(status: GameStateStatus.loading));

    try {
      String finalImageUrl = event.game.imageUrl;

      if (event.imageFile != null) {
        finalImageUrl = await gameRepository.uploadGameCover(event.imageFile!);
      }

      final gameToSave = GameModel(
        id: event.game.id,
        title: event.game.title,
        imageUrl: finalImageUrl,
        genre: event.game.genre,
        description: event.game.description,
        releaseDate: event.game.releaseDate,
        status: event.game.status,
      );

      await gameRepository.addGame(gameToSave);
      emit(state.copyWith(status: GameStateStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: GameStateStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nic_backlog/data/models/game_model.dart';
import 'package:nic_backlog/data/repositories/game_repository.dart';
import 'package:nic_backlog/logic/game/game_event.dart';
import 'package:nic_backlog/logic/game/game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GameRepository gameRepository;

  GameBloc({required this.gameRepository}) : super(const GameState()) {
    on<FetchGamesRequested>(_onFetchGamesRequested);
    on<FetchGameDetailRequested>(_onFetchGameDetailRequested);
    on<AddGameRequested>(_onAddGameRequested);
    on<UpdateGameRequested>(_onUpdateGameRequested);
  }

  Future<void> _onFetchGamesRequested(
    FetchGamesRequested event,
    Emitter<GameState> emit,
  ) async {
    emit(state.copyWith(status: GameStateStatus.loading));

    try {
      final games = await gameRepository.fetchGames();
      emit(state.copyWith(status: GameStateStatus.success, games: games));
    } catch (e) {
      final cleanError = e.toString().replaceAll('Exception: ', '');
      emit(
        state.copyWith(
          status: GameStateStatus.failure,
          errorMessage: cleanError,
        ),
      );
    }
  }

  Future<void> _onFetchGameDetailRequested(
    FetchGameDetailRequested event,
    Emitter<GameState> emit,
  ) async {
    emit(state.copyWith(status: GameStateStatus.loading));
    try {
      final gameDetail = await gameRepository.fetchGameById(event.gameId);
      emit(
        state.copyWith(
          status: GameStateStatus.success,
          selectedGame: gameDetail,
        ),
      );
    } catch (e) {
      final cleanError = e.toString().replaceAll('Exception: ', '');
      emit(
        state.copyWith(
          status: GameStateStatus.failure,
          errorMessage: cleanError,
        ),
      );
    }
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

  Future<void> _onUpdateGameRequested(
    UpdateGameRequested event,
    Emitter<GameState> emit,
  ) async {
    emit(state.copyWith(status: GameStateStatus.loading));
    try {
      await gameRepository.updateGame(
        game: event.game,
        imageFile: event.imageFile,
      );
      final updatedGames = await gameRepository.fetchGames();

      emit(
        state.copyWith(
          status: GameStateStatus.success,
          games: updatedGames,
          selectedGame: state.selectedGame?.id == event.game.id
              ? event.game
              : state.selectedGame,
        ),
      );
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

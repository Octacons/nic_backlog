import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nic_backlog/data/models/game_model.dart';
import 'package:nic_backlog/data/repositories/game_repository.dart';
import 'package:nic_backlog/logic/game/game_event.dart';
import 'package:nic_backlog/logic/game/game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GameRepository gameRepository;

  GameBloc({required this.gameRepository}) : super(GameInitial()) {
    on<FetchGamesRequested>(_onFetchGamesRequested);
    on<FetchGameDetailRequested>(_onFetchGameDetailRequested);
    on<AddGameRequested>(_onAddGameRequested);
    on<UpdateGameRequested>(_onUpdateGameRequested);
  }

  Future<void> _onFetchGamesRequested(
    FetchGamesRequested event,
    Emitter<GameState> emit,
  ) async {
    final currentSelected = state is GameSuccess
        ? (state as GameSuccess).selectedGame
        : null;
    emit(GameLoading());

    try {
      final games = await gameRepository.fetchGames();
      emit(GameSuccess(games: games, selectedGame: currentSelected));
    } catch (e) {
      final cleanError = e.toString().replaceAll('Exception: ', '');
      emit(GameFailure(cleanError));
    }
  }

  Future<void> _onFetchGameDetailRequested(
    FetchGameDetailRequested event,
    Emitter<GameState> emit,
  ) async {
    final currentGames = state is GameSuccess
        ? (state as GameSuccess).games
        : const <GameModel>[];
    emit(GameLoading());
    try {
      final gameDetail = await gameRepository.fetchGameById(event.gameId);
      emit(GameSuccess(games: currentGames, selectedGame: gameDetail));
    } catch (e) {
      final cleanError = e.toString().replaceAll('Exception: ', '');
      emit(GameFailure(cleanError));
    }
  }

  Future<void> _onAddGameRequested(
    AddGameRequested event,
    Emitter<GameState> emit,
  ) async {
    final currentSelected = state is GameSuccess
        ? (state as GameSuccess).selectedGame
        : null;
    emit(GameLoading());

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
      final updatedGames = await gameRepository.fetchGames();
      emit(GameSuccess(games: updatedGames, selectedGame: currentSelected));
    } catch (e) {
      emit(GameFailure(e.toString()));
    }
  }

  Future<void> _onUpdateGameRequested(
    UpdateGameRequested event,
    Emitter<GameState> emit,
  ) async {
    final currentSelected = state is GameSuccess
        ? (state as GameSuccess).selectedGame
        : null;
    emit(GameLoading());
    try {
      await gameRepository.updateGame(
        game: event.game,
        imageFile: event.imageFile,
      );
      final updatedGames = await gameRepository.fetchGames();

      emit(
        GameSuccess(
          games: updatedGames,
          selectedGame: currentSelected?.id == event.game.id
              ? event.game
              : currentSelected,
        ),
      );
    } catch (e) {
      emit(GameFailure(e.toString()));
    }
  }
}

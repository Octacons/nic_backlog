import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nic_backlog/data/repositories/game_log_repository.dart';
import 'package:nic_backlog/logic/game_log/game_log_event.dart';
import 'package:nic_backlog/logic/game_log/game_log_state.dart';
import 'package:nic_backlog/utils/app_logger.dart';

class GameLogBloc extends Bloc<GameLogEvent, GameLogState> {
  final GameLogRepository _gameLogRepository;

  GameLogBloc({required GameLogRepository gameLogRepository})
    : _gameLogRepository = gameLogRepository,
      super(const GameLogState()) {
    on<FetchGameLogsRequested>(_onFetchGameLogsRequested);
    on<AddGameLogRequested>(_onAddGameLogRequested);
    on<DeleteGameLogRequested>(_onDeleteGameLogRequested);
  }

  Future<void> _onFetchGameLogsRequested(
    FetchGameLogsRequested event,
    Emitter<GameLogState> emit,
  ) async {
    emit(state.copyWith(status: GameLogStatus.loading));
    try {
      AppLogger.debug(
        'Fetching logs untuk game: ${event.gameId}',
        name: 'GameLogBloc',
      );
      final logs = await _gameLogRepository.fetchGameLogs(event.gameId);
      emit(state.copyWith(status: GameLogStatus.success, logs: logs));
    } catch (e) {
      AppLogger.error('Gagal fetch logs: $e', name: 'GameLogBloc', error: e);
      emit(
        state.copyWith(
          status: GameLogStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddGameLogRequested(
    AddGameLogRequested event,
    Emitter<GameLogState> emit,
  ) async {
    emit(state.copyWith(status: GameLogStatus.loading));
    try {
      AppLogger.debug(
        'Menambahkan log ke game: ${event.gameId}',
        name: 'GameLogBloc',
      );
      await _gameLogRepository.addGameLog(event.gameId, event.log);

      // Re-fetch log list terbaru agar state sinkron
      final updatedLogs = await _gameLogRepository.fetchGameLogs(event.gameId);
      emit(state.copyWith(status: GameLogStatus.success, logs: updatedLogs));
    } catch (e) {
      AppLogger.error('Gagal add log: $e', name: 'GameLogBloc', error: e);
      emit(
        state.copyWith(
          status: GameLogStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteGameLogRequested(
    DeleteGameLogRequested event,
    Emitter<GameLogState> emit,
  ) async {
    emit(state.copyWith(status: GameLogStatus.loading));
    try {
      AppLogger.debug(
        'Menghapus log ${event.logId} dari game: ${event.gameId}',
        name: 'GameLogBloc',
      );
      await _gameLogRepository.deleteGameLog(event.gameId, event.logId);

      final updatedLogs = await _gameLogRepository.fetchGameLogs(event.gameId);
      emit(state.copyWith(status: GameLogStatus.success, logs: updatedLogs));
    } catch (e) {
      AppLogger.error('Gagal delete log: $e', name: 'GameLogBloc', error: e);
      emit(
        state.copyWith(
          status: GameLogStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}

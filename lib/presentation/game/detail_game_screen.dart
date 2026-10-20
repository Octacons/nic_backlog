import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nic_backlog/data/models/game_model.dart';
import 'package:nic_backlog/data/repositories/game_log_repository.dart';
import 'package:nic_backlog/logic/game/game_bloc.dart';
import 'package:nic_backlog/logic/game/game_event.dart';
import 'package:nic_backlog/logic/game/game_state.dart';
import 'package:nic_backlog/logic/game_log/game_log_bloc.dart';
import 'package:nic_backlog/logic/game_log/game_log_event.dart';
import 'package:nic_backlog/presentation/game/create_update_game_screen.dart';
import 'package:nic_backlog/utils/app_theme.dart';

import 'widgets/game_detail_body.dart';
import 'widgets/game_log_list_widget.dart';

class GameDetailScreen extends StatefulWidget {
  final String gameId;

  const GameDetailScreen({super.key, required this.gameId});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  @override
  void initState() {
    super.initState();

    context.read<GameBloc>().add(
      FetchGameDetailRequested(gameId: widget.gameId),
    );
  }

  Future<void> _confirmDeleteGame(
    BuildContext context,
    GameModel game,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("HAPUS GAME"),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${game.title}" beserta seluruh jurnal permainannya?',
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text("BATAL"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 2),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text("HAPUS"),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      context.read<GameBloc>().add(DeleteGameRequested(gameId: game.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameLogBloc>(
      lazy: false,
      create: (context) =>
          GameLogBloc(gameLogRepository: context.read<GameLogRepository>())
            ..add(FetchGameLogsRequested(gameId: widget.gameId)),

      child: BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {
          switch (state) {
            case GameInitial():
            case GameLoading():
              break;
            case GameFailure(:final errorMessage):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: AppColors.error,
                ),
              );
            case GameSuccess(:final selectedGame):
              if (selectedGame == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("GAME BERHASIL DIHAPUS"),
                    backgroundColor: AppColors.success,
                  ),
                );

                Navigator.pop(context);
              }
          }
        },

        builder: (context, state) {
          final game = switch (state) {
            GameSuccess(:final selectedGame) => selectedGame,
            GameInitial() || GameLoading() || GameFailure() => null,
          };

          return Scaffold(
            appBar: AppBar(
              title: const Text("GAME DETAIL"),
              actions: [
                if (game != null)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateUpdateGameScreen(game: game),
                          ),
                        );
                      } else if (value == 'delete') {
                        _confirmDeleteGame(context, game);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: AppColors.textPrimary,
                            ),
                            SizedBox(width: 10),
                            Text('EDIT GAME'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: AppColors.error,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'DELETE GAME',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            body: _buildBody(state),
          );
        },
      ),
    );
  }

  Widget _buildBody(GameState state) {
    return switch (state) {
      GameInitial() || GameLoading() => const Center(
        child: CircularProgressIndicator(),
      ),
      GameFailure(:final errorMessage) => Center(
        child: Text(
          errorMessage,
          style: AppTextStyles.body.copyWith(color: AppColors.error),
        ),
      ),
      GameSuccess(:final selectedGame) =>
        selectedGame == null
            ? const Center(
                child: Text(
                  "DETAIL GAME TIDAK DITEMUKAN.",
                  style: AppTextStyles.overline,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GameDetailBody(game: selectedGame),
                    const SizedBox(height: 16),
                    GameLogListWidget(gameId: widget.gameId),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
    };
  }
}

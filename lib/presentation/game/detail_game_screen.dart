import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nic_backlog/data/repositories/game_log_repository.dart';
import 'package:nic_backlog/logic/game/game_bloc.dart';
import 'package:nic_backlog/logic/game/game_event.dart';
import 'package:nic_backlog/logic/game/game_state.dart';
import 'package:nic_backlog/logic/game_log/game_log_bloc.dart';
import 'package:nic_backlog/logic/game_log/game_log_event.dart';
import 'package:nic_backlog/presentation/game/create_update_game_screen.dart';

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
                  backgroundColor: Colors.red,
                ),
              );
            case GameSuccess(:final selectedGame):
              if (selectedGame == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Game berhasil dihapus"),
                    backgroundColor: Colors.green,
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
              title: const Text("Game Detail"),
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
                      } else if (value == 'delete') {}
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20),
                            SizedBox(width: 8),
                            Text('Delete'),
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
          style: const TextStyle(color: Colors.red),
        ),
      ),
      GameSuccess(:final selectedGame) =>
        selectedGame == null
            ? const Center(child: Text("Detail game tidak ditemukan."))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GameDetailBody(game: selectedGame),
                    const SizedBox(height: 8),
                    GameLogListWidget(gameId: widget.gameId),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
    };
  }
}

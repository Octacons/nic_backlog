import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nic_backlog/logic/game_log/game_log_bloc.dart';
import 'package:nic_backlog/logic/game_log/game_log_event.dart';
import 'package:nic_backlog/logic/game_log/game_log_state.dart';
import 'package:nic_backlog/presentation/game/create_update_game_log_screen.dart';

class GameLogListWidget extends StatelessWidget {
  final String gameId;

  const GameLogListWidget({super.key, required this.gameId});

  void _navigateToForm(BuildContext context, {dynamic gameLog}) {
    final gameLogBloc = context.read<GameLogBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: gameLogBloc,
          child: CreateUpdateGameLogScreen(
            gameId: gameId,
            // Tambahkan parameter gameLog untuk mode edit
            // jika sudah tersedia di screen kamu.
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String title) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Hapus Log"),
          content: Text('Apakah Anda yakin ingin menghapus log "$title"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Batal"),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Game Logs & Jurnal",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.redAccent),
                onPressed: () => _navigateToForm(context),
              ),
            ],
          ),

          const SizedBox(height: 8),

          BlocBuilder<GameLogBloc, GameLogState>(
            builder: (context, state) {
              return switch (state) {
                GameLogInitial() || GameLogLoading() => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                GameLogFailure(:final errorMessage) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                GameLogSuccess(:final logs) =>
                  logs.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              "Belum ada log permainan.\n"
                              "Klik tombol + untuk menambah jurnal baru!",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];

                            final dateStr =
                                "${log.date.day.toString().padLeft(2, '0')}/"
                                "${log.date.month.toString().padLeft(2, '0')}/"
                                "${log.date.year}";

                            return Dismissible(
                              key: Key(log.id),
                              direction: DismissDirection.endToStart,

                              background: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Hapus",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              confirmDismiss: (_) {
                                return _confirmDelete(context, log.title);
                              },

                              onDismissed: (_) {
                                context.read<GameLogBloc>().add(
                                  DeleteGameLogRequested(
                                    gameId: gameId,
                                    logId: log.id,
                                  ),
                                );
                              },

                              child: Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  onTap: () {
                                    _navigateToForm(context, gameLog: log);
                                  },

                                  title: Text(
                                    log.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tanggal: $dateStr",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        log.note,
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),

                                  trailing: log.rating != null
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                size: 14,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                log.rating!.toStringAsFixed(1),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
              };
            },
          ),
        ],
      ),
    );
  }
}

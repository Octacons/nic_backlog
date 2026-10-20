import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nic_backlog/data/models/game_log_model.dart';
import 'package:nic_backlog/logic/game_log/game_log_bloc.dart';
import 'package:nic_backlog/logic/game_log/game_log_event.dart';
import 'package:nic_backlog/logic/game_log/game_log_state.dart';
import 'package:nic_backlog/presentation/game/create_update_game_log_screen.dart';
import 'package:nic_backlog/utils/app_theme.dart';

class GameLogListWidget extends StatelessWidget {
  final String gameId;

  const GameLogListWidget({super.key, required this.gameId});

  void _navigateToForm(BuildContext context, {GameLogModel? gameLog}) {
    final gameLogBloc = context.read<GameLogBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: gameLogBloc,
          child: CreateUpdateGameLogScreen(
            gameId: gameId,
            gameLog: gameLog,
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
          title: const Text("HAPUS LOG"),
          content: Text('Apakah Anda yakin ingin menghapus log "$title"?'),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("BATAL"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 2),
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text("HAPUS"),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: AppColors.borderStrong, thickness: 2),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SESSION ENTRIES",
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "GAME LOGS & JURNAL",
                    style: AppTextStyles.subhead,
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text("NEW LOG"),
                onPressed: () => _navigateToForm(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

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
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
                GameLogSuccess(:final logs) =>
                  logs.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(
                              color: AppColors.borderSubtle,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            "Belum ada log permainan.\n"
                            "Klik tombol '+ NEW LOG' untuk menambah jurnal baru!",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall,
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

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Dismissible(
                                key: Key(log.id),
                                direction: DismissDirection.endToStart,

                                background: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    border: Border.all(
                                      color: AppColors.error,
                                      width: 2,
                                    ),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Icon(
                                        Icons.delete_outline,
                                        color: AppColors.tertiary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "HAPUS",
                                        style: AppTextStyles.button,
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

                                child: InkWell(
                                  onTap: () {
                                    _navigateToForm(context, gameLog: log);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: AppColors.background,
                                      border: Border(
                                        left: BorderSide(
                                          color: AppColors.borderStrong,
                                          width: 4,
                                        ),
                                        top: BorderSide(
                                          color: AppColors.borderSubtle,
                                          width: 2,
                                        ),
                                        right: BorderSide(
                                          color: AppColors.borderSubtle,
                                          width: 2,
                                        ),
                                        bottom: BorderSide(
                                          color: AppColors.borderSubtle,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "DATE // $dateStr",
                                                    style: AppTextStyles
                                                        .overline
                                                        .copyWith(
                                                          color: AppColors
                                                              .textTertiary,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    log.title,
                                                    style: AppTextStyles.body
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (log.rating != null)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  border: Border.all(
                                                    color:
                                                        AppColors.borderStrong,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.star,
                                                      size: 12,
                                                      color: AppColors.tertiary,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      log.rating!
                                                          .toStringAsFixed(1),
                                                      style: AppTextStyles
                                                          .overline
                                                          .copyWith(
                                                            color: AppColors
                                                                .tertiary,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          log.note,
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
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

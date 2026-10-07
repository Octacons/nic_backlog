import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nic_backlog/data/models/gamelog_model.dart';
import 'package:nic_backlog/logic/game/game_bloc.dart';
import 'package:nic_backlog/logic/game/game_event.dart';
import 'package:nic_backlog/logic/game/game_state.dart';

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
    // Cukup lempar event ke BLoC, gak perlu panggil repository langsung
    context.read<GameBloc>().add(
      FetchGameDetailRequested(gameId: widget.gameId),
    );
  }

  Widget _buildGameCover(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      final base64Data = imageUrl.split(',').last;
      final bytes = base64Decode(base64Data);
      return Image.memory(bytes, fit: BoxFit.cover, width: double.infinity);
    }

    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[800],
          child: const Icon(
            Icons.broken_image,
            size: 50,
            color: Colors.white54,
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey[800],
      child: const Icon(Icons.gamepad, size: 50, color: Colors.white54),
    );
  }

  void _showAddLogBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    final ratingController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tambah Game Log",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Judul Log / Activity",
                  hintText: "Misal: Selesai Chapter 1",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Catatan Progress / Impresi",
                  hintText: "Misal: Boss pertamanya gampang banget!",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ratingController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Rating Sesi Ini (Opsional 1.0 - 5.0)",
                  hintText: "4.5",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.star_outline),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    final title = titleController.text.trim();
                    final note = noteController.text.trim();
                    final rating = double.tryParse(ratingController.text);

                    if (title.isEmpty || note.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Judul dan Catatan wajib diisi."),
                        ),
                      );
                      return;
                    }

                    final newLog = GameLogModel(
                      id: '',
                      title: title,
                      note: note,
                      date: DateTime.now(),
                      rating: rating,
                    );

                    // Kirim event ke BLoC untuk add log
                    context.read<GameBloc>().add(
                      AddGameLogRequested(gameId: widget.gameId, log: newLog),
                    );

                    Navigator.pop(bottomSheetContext);
                  },
                  child: const Text(
                    "Simpan Log",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Game Detail")),
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          if (state.status == GameStateStatus.loading &&
              state.selectedGame == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final game = state.selectedGame;

          if (game == null) {
            return const Center(child: Text("Detail game tidak ditemukan."));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildGameCover(game.imageUrl),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              game.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              game.status.name.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            label: Text(game.genre),
                            avatar: const Icon(Icons.category, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(
                              "${game.releaseDate.day}/${game.releaseDate.month}/${game.releaseDate.year}",
                            ),
                            avatar: const Icon(Icons.calendar_today, size: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 24),
                          const SizedBox(width: 4),
                          Text(
                            "${game.overallRating.toStringAsFixed(1)} / 5.0",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Deskripsi Game",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        game.description.isNotEmpty
                            ? game.description
                            : "Tidak ada deskripsi.",
                        style: TextStyle(color: Colors.black, height: 1.4),
                      ),

                      const Divider(height: 32, thickness: 1),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Game Logs & Jurnal",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _showAddLogBottomSheet(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (game.logs.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              "Belum ada log permainan.\nKlik tombol + untuk menambah jurnal baru!",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: game.logs.length,
                          itemBuilder: (context, index) {
                            final log = game.logs[index];
                            final dateStr =
                                "${log.date.day}/${log.date.month}/${log.date.year}";

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(
                                  log.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(log.note),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Tanggal: $dateStr",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
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
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

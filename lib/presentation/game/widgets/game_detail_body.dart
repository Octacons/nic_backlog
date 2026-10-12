import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nic_backlog/data/models/game_model.dart';

class GameDetailBody extends StatelessWidget {
  final GameModel game;

  const GameDetailBody({super.key, required this.game});

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
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[800],
            child: const Icon(
              Icons.broken_image,
              size: 50,
              color: Colors.white54,
            ),
          );
        },
      );
    }

    return Container(
      color: Colors.grey[800],
      child: const Icon(Icons.gamepad, size: 50, color: Colors.white54),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(aspectRatio: 16 / 9, child: _buildGameCover(game.imageUrl)),

        Padding(
          padding: const EdgeInsets.all(16),
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

              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.category, size: 16),
                    label: Text(game.genre),
                  ),
                  Chip(
                    avatar: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      "${game.releaseDate.day}/${game.releaseDate.month}/${game.releaseDate.year}",
                    ),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              Text(
                game.description.isNotEmpty
                    ? game.description
                    : "Tidak ada deskripsi.",
                style: const TextStyle(height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nic_backlog/data/models/game_model.dart';
import 'package:nic_backlog/utils/app_theme.dart';

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
            color: AppColors.surface,
            child: const Icon(
              Icons.broken_image_outlined,
              size: 50,
              color: AppColors.textSecondary,
            ),
          );
        },
      );
    }

    return Container(
      color: AppColors.primary,
      child: const Icon(Icons.gamepad, size: 50, color: AppColors.tertiary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final releaseDateStr =
        "${game.releaseDate.day.toString().padLeft(2, '0')}/"
        "${game.releaseDate.month.toString().padLeft(2, '0')}/"
        "${game.releaseDate.year}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.borderStrong, width: 2),
            ),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildGameCover(game.imageUrl),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "${game.genre.toUpperCase()}  •  RELEASED $releaseDateStr",
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppTheme.buildStatusChip(game.status),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                game.title,
                style: AppTextStyles.headline,
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  border: Border.all(color: AppColors.borderStrong, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: AppColors.tertiary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "RATING: ${game.overallRating.toStringAsFixed(1)} / 5.0",
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "SYNOPSIS & EDITORIAL NOTES",
                style: AppTextStyles.overline,
              ),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    left: BorderSide(color: AppColors.secondary, width: 4),
                    top: BorderSide(color: AppColors.borderSubtle, width: 1),
                    right: BorderSide(color: AppColors.borderSubtle, width: 1),
                    bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
                  ),
                ),
                child: Text(
                  game.description.isNotEmpty
                      ? game.description
                      : "Tidak ada deskripsi.",
                  style: AppTextStyles.body,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

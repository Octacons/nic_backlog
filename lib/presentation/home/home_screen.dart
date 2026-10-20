import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nic_backlog/logic/auth/auth_bloc.dart';
import 'package:nic_backlog/logic/auth/auth_event.dart';
import 'package:nic_backlog/logic/auth/auth_state.dart';
import 'package:nic_backlog/logic/game/game_bloc.dart';
import 'package:nic_backlog/logic/game/game_event.dart';
import 'package:nic_backlog/logic/game/game_state.dart';
import 'package:nic_backlog/presentation/auth/login_screen.dart';
import 'package:nic_backlog/presentation/game/create_update_game_screen.dart';
import 'package:nic_backlog/presentation/game/detail_game_screen.dart';
import 'package:nic_backlog/utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GameBloc>().add(const FetchGamesRequested());
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
          color: AppColors.surface,
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 40,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
      color: AppColors.primary,
      child: const Center(
        child: Icon(Icons.gamepad, size: 40, color: AppColors.tertiary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state) {
          case AuthInitial():
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          case AuthFailure(:final error):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: AppColors.error,
              ),
            );
          case AuthLoading():
          case AuthSuccess():
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("NIC-BACKLOG"),
        ),
        drawer: Drawer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  border: Border(
                    bottom: BorderSide(color: AppColors.secondary, width: 4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GAMING ARCHIVE',
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'NIC-BACKLOG',
                      style: AppTextStyles.subhead.copyWith(
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SafeArea(
                top: false,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.borderStrong, width: 2),
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                    title: Text(
                      'LOG OUT',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      context.read<AuthBloc>().add(LogoutRequested());
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.background,
          onRefresh: () async {
            context.read<GameBloc>().add(const FetchGamesRequested());
          },
          child: BlocBuilder<GameBloc, GameState>(
            builder: (context, state) {
              return switch (state) {
                GameInitial() || GameLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                GameFailure(:final errorMessage) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<GameBloc>().add(
                              const FetchGamesRequested(),
                            );
                          },
                          child: const Text("COBA LAGI"),
                        ),
                      ],
                    ),
                  ),
                ),
                GameSuccess(:final games) =>
                  games.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Container(
                              padding: const EdgeInsets.all(24.0),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                border: Border.all(
                                  color: AppColors.borderStrong,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "EMPTY ARCHIVE",
                                    style: AppTextStyles.overline,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "NO GAMES YET",
                                    style: AppTextStyles.subhead,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Belum ada game di backlog kamu.\nKlik tombol '+ ADD GAME' untuk menambahkan!",
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                          itemCount: games.length,
                          itemBuilder: (context, index) {
                            final game = games[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          GameDetailScreen(gameId: game.id),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: AppColors.background,
                                    border: Border(
                                      top: BorderSide(
                                        color: AppColors.borderStrong,
                                        width: 2,
                                      ),
                                      left: BorderSide(
                                        color: AppColors.borderStrong,
                                        width: 2,
                                      ),
                                      right: BorderSide(
                                        color: AppColors.borderStrong,
                                        width: 2,
                                      ),
                                      bottom: BorderSide(
                                        color: AppColors.borderStrong,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Render Cover Game dengan Rasio 16:9
                                      Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: AppColors.borderStrong,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        child: AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: _buildGameCover(game.imageUrl),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        game.genre
                                                            .toUpperCase(),
                                                        style: AppTextStyles
                                                            .overline
                                                            .copyWith(
                                                              color: AppColors
                                                                  .textSecondary,
                                                            ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        game.title,
                                                        style: AppTextStyles
                                                            .subhead,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                AppTheme.buildStatusChip(
                                                  game.status,
                                                ),
                                              ],
                                            ),
                                            if (game
                                                .description
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 12),
                                              Text(
                                                game.description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTextStyles.bodySmall,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              };
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateUpdateGameScreen(),
              ),
            );
          },
          icon: const Icon(Icons.add, color: AppColors.tertiary, size: 18),
          label: const Text("ADD GAME"),
        ),
      ),
    );
  }
}

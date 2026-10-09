import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nic_backlog/data/repositories/auth_repository.dart';
import 'package:nic_backlog/data/repositories/game_log_repository.dart';
import 'package:nic_backlog/data/repositories/game_repository.dart';
import 'package:nic_backlog/logic/auth/auth_bloc.dart';
import 'package:nic_backlog/logic/game/game_bloc.dart';
import 'package:nic_backlog/presentation/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),

        RepositoryProvider<GameRepository>(
          create: (context) => GameRepository(),
        ),

        RepositoryProvider<GameLogRepository>(
          create: (context) => GameLogRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider<GameBloc>(
            create: (context) =>
                GameBloc(gameRepository: context.read<GameRepository>()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nic BackLog',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 178, 0, 0),
            ),
          ),
          home: const LoginScreen(),
        ),
      ),
    );
  }
}

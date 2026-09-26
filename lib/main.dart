import 'package:flutter/material.dart';
import 'package:nic_backlog/ui/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nic BackLog',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: const Color.fromARGB(255, 178, 0, 0)),
      ),
      home: HomeScreen(),
    );
  }
}

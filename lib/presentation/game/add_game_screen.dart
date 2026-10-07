// lib/presentation/game/add_game_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nic_backlog/data/models/game_model.dart';
import 'package:nic_backlog/logic/game/game_bloc.dart';
import 'package:nic_backlog/logic/game/game_event.dart';
import 'package:nic_backlog/logic/game/game_state.dart';

class AddGameScreen extends StatefulWidget {
  const AddGameScreen({super.key});

  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _genreController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedReleaseDate;
  GameStatus _selectedStatus = GameStatus.backlogged;

  @override
  void dispose() {
    _titleController.dispose();
    _imageUrlController.dispose();
    _genreController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Helper Date Picker
  Future<void> _pickReleaseDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedReleaseDate = pickedDate;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedReleaseDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pilih tanggal rilis game terlebih dahulu!"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // 1. Rakit Objek GameModel dari Input UI
      final newGame = GameModel(
        id: '', // Generated otomatis oleh Firestore nantinya
        title: _titleController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        genre: _genreController.text.trim(),
        description: _descriptionController.text.trim(),
        releaseDate: _selectedReleaseDate!,
        status: _selectedStatus,
      );

      // 2. Lempar Event ke GameBloc via Provider
      context.read<GameBloc>().add(AddGameRequested(newGame));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Game")),
      body: BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {
          if (state.status == GameStateStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Game berhasil ditambahkan!"),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context); // Kembali ke Dashboard
          } else if (state.status == GameStateStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? "Gagal menambahkan game"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == GameStateStatus.loading;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Input
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: "Game Title *",
                      hintText: "e.g. Zelda: Breath of the Wild",
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? "Title is required"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Image URL Input
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: "Image Cover URL",
                      hintText: "https://example.com/poster.jpg",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Genre Input
                  TextFormField(
                    controller: _genreController,
                    decoration: const InputDecoration(
                      labelText: "Genre *",
                      hintText: "e.g. Action RPG, Open World",
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? "Genre is required"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Status Dropdown
                  DropdownButtonFormField<GameStatus>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: "Game Status",
                      border: OutlineInputBorder(),
                    ),
                    items: GameStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedStatus = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date Picker Section
                  InkWell(
                    onTap: () => _pickReleaseDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Release Date *",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _selectedReleaseDate == null
                            ? "Select Date"
                            : DateFormat(
                                'dd MMMM yyyy',
                              ).format(_selectedReleaseDate!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Input
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Description / Notes",
                      hintText: "Short synopsis or personal notes...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitForm,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "SAVE GAME",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

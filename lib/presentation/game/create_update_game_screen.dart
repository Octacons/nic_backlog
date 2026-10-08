import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nic_backlog/data/models/game_model.dart';
import 'package:nic_backlog/logic/game/game_bloc.dart';
import 'package:nic_backlog/logic/game/game_event.dart';
import 'package:nic_backlog/logic/game/game_state.dart';

class CreateUpdateGameScreen extends StatefulWidget {
  final GameModel? game;

  const CreateUpdateGameScreen({super.key, this.game});

  @override
  State<CreateUpdateGameScreen> createState() => _CreateUpdateGameScreenState();
}

class _CreateUpdateGameScreenState extends State<CreateUpdateGameScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _genreController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedReleaseDate;
  GameStatus _selectedStatus = GameStatus.backlogged;
  File? _selectedImageFile;

  bool get _isEditMode => widget.game != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _titleController.text = widget.game!.title;
      _genreController.text = widget.game!.genre;
      _descriptionController.text = widget.game!.description;
      _selectedReleaseDate = widget.game!.releaseDate;
      _selectedStatus = widget.game!.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _genreController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  ImageProvider? _getCoverImageProvider() {
    if (_selectedImageFile != null) {
      return FileImage(_selectedImageFile!);
    }

    final existingImage = widget.game?.imageUrl;
    if (existingImage != null && existingImage.isNotEmpty) {
      if (existingImage.startsWith('data:image')) {
        final base64Clean = existingImage.split(',').last;
        return MemoryImage(base64Decode(base64Clean));
      } else {
        return NetworkImage(existingImage);
      }
    }
    return null;
  }

  Future<void> _pickAndCropImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null || !mounted) return;

    final primaryColor = Theme.of(context).primaryColor;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressQuality: 60,
      maxWidth: 800,
      maxHeight: 450,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Cover Image (16:9)',
          toolbarColor: primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio16x9,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Cover Image (16:9)',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (!mounted) return;

    if (croppedFile != null) {
      setState(() {
        _selectedImageFile = File(croppedFile.path);
      });
    }
  }

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
      if (_selectedImageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Upload foto cover game terlebih dahulu!"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_selectedReleaseDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pilih tanggal rilis game terlebih dahulu!"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final newGame = GameModel(
        id: '',
        title: _titleController.text.trim(),
        imageUrl: '',
        genre: _genreController.text.trim(),
        description: _descriptionController.text.trim(),
        releaseDate: _selectedReleaseDate!,
        status: _selectedStatus,
      );

      context.read<GameBloc>().add(
        AddGameRequested(game: newGame, imageFile: _selectedImageFile),
      );
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
            Navigator.pop(context);
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
                  GestureDetector(
                    onTap: _pickAndCropImage,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Builder(
                        builder: (context) {
                          final imageProvider = _getCoverImageProvider();

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[400]!),
                              image: imageProvider != null
                                  ? DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: imageProvider == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.add_a_photo,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "Tap to Upload Cover (16:9)",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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

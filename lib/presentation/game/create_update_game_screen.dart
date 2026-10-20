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
import 'package:nic_backlog/utils/app_theme.dart';

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

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressQuality: 60,
      maxWidth: 800,
      maxHeight: 450,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Cover Image (16:9)',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: AppColors.tertiary,
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
      initialDate: _selectedReleaseDate ?? DateTime.now(),
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
      final hasImage =
          _selectedImageFile != null ||
          (widget.game?.imageUrl.isNotEmpty ?? false);

      if (!hasImage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("UPLOAD FOTO COVER GAME TERLEBIH DAHULU!"),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      if (_selectedReleaseDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("PILIH TANGGAL RILIS GAME TERLEBIH DAHULU!"),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
      if (_isEditMode) {
        final updatedGame = widget.game!.copyWith(
          title: _titleController.text.trim(),
          genre: _genreController.text.trim(),
          description: _descriptionController.text.trim(),
          releaseDate: _selectedReleaseDate!,
          status: _selectedStatus,
        );

        context.read<GameBloc>().add(
          UpdateGameRequested(game: updatedGame, imageFile: _selectedImageFile),
        );
      } else {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? "EDIT GAME" : "ADD NEW GAME"),
      ),
      body: BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {
          switch (state) {
            case GameInitial():
            case GameLoading():
              break;
            case GameSuccess():
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isEditMode
                        ? "GAME BERHASIL DIPERBARUI!"
                        : "GAME BERHASIL DITAMBAHKAN!",
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context);
            case GameFailure(:final errorMessage):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: AppColors.error,
                ),
              );
          }
        },
        builder: (context, state) {
          final isLoading = switch (state) {
            GameLoading() => true,
            GameInitial() || GameSuccess() || GameFailure() => false,
          };

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "COVER ARTWORK // 16:9",
                    style: AppTextStyles.overline,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickAndCropImage,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Builder(
                        builder: (context) {
                          final imageProvider = _getCoverImageProvider();

                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border: Border.all(
                                color: AppColors.borderStrong,
                                width: 2,
                              ),
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
                                    children: [
                                      const Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 36,
                                        color: AppColors.textPrimary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "TAP TO UPLOAD COVER (16:9)",
                                        style: AppTextStyles.overline.copyWith(
                                          color: AppColors.textSecondary,
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
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: "GAME TITLE *",
                      hintText: "e.g. Zelda: Breath of the Wild",
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? "Title is required"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _genreController,
                    decoration: const InputDecoration(
                      labelText: "GENRE *",
                      hintText: "e.g. Action RPG, Open World",
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? "Genre is required"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<GameStatus>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: "GAME STATUS",
                    ),
                    items: GameStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(
                          status.name.toUpperCase(),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
                        labelText: "RELEASE DATE *",
                        suffixIcon: Icon(Icons.calendar_today, size: 18),
                      ),
                      child: Text(
                        _selectedReleaseDate == null
                            ? "Select Date"
                            : DateFormat(
                                'dd MMMM yyyy',
                              ).format(_selectedReleaseDate!),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: _selectedReleaseDate == null
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "DESCRIPTION / NOTES",
                      hintText: "Short synopsis or personal notes...",
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitForm,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.tertiary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(_isEditMode ? "UPDATE GAME" : "SAVE GAME"),
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

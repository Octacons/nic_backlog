import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nic_backlog/data/models/game_log_model.dart';
import 'package:nic_backlog/logic/game_log/game_log_bloc.dart';
import 'package:nic_backlog/logic/game_log/game_log_event.dart';
import 'package:nic_backlog/logic/game_log/game_log_state.dart';

class CreateUpdateGameLogScreen extends StatefulWidget {
  final String gameId;
  final GameLogModel? gameLog;

  const CreateUpdateGameLogScreen({
    super.key,
    required this.gameId,
    this.gameLog,
  });

  @override
  State<CreateUpdateGameLogScreen> createState() =>
      _CreateUpdateGameLogScreenState();
}

class _CreateUpdateGameLogScreenState extends State<CreateUpdateGameLogScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late final TextEditingController _ratingController;
  late DateTime _selectedDate;

  bool get isEditing => widget.gameLog != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.gameLog?.title ?? '');
    _noteController = TextEditingController(text: widget.gameLog?.note ?? '');
    _ratingController = TextEditingController(
      text: widget.gameLog?.rating != null
          ? widget.gameLog!.rating.toString()
          : '',
    );
    _selectedDate = widget.gameLog?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final note = _noteController.text.trim();
    final ratingText = _ratingController.text.trim();
    final rating = ratingText.isNotEmpty ? double.tryParse(ratingText) : null;

    final logData = GameLogModel(
      id: widget.gameLog?.id ?? '',
      title: title,
      note: note,
      date: _selectedDate,
      rating: rating,
    );

    if (isEditing) {
      context.read<GameLogBloc>().add(
        UpdateGameLogRequested(gameId: widget.gameId, log: logData),
      );
    } else {
      context.read<GameLogBloc>().add(
        AddGameLogRequested(gameId: widget.gameId, log: logData),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final log = widget.gameLog;
    if (log == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Hapus Log"),
          content: Text('Apakah Anda yakin ingin menghapus log "${log.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text("Batal"),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      context.read<GameLogBloc>().add(
        DeleteGameLogRequested(gameId: widget.gameId, logId: log.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}";

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Jurnal" : "Tambah Jurnal"),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: "Hapus Log",
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: BlocListener<GameLogBloc, GameLogState>(
        listener: (context, state) {
          switch (state) {
            case GameLogInitial():
            case GameLogLoading():
              break;
            case GameLogFailure(:final errorMessage):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            case GameLogSuccess():
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEditing
                        ? "Jurnal berhasil diperbarui"
                        : "Jurnal berhasil ditambahkan",
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Judul Log / Aktivitas",
                    hintText: "Misal: Selesai Chapter 1 / Tamat",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "Judul wajib diisi"
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Catatan Gameplay",
                    hintText:
                        "Tulis progres, impresi cerita, atau build karakter...",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "Catatan wajib diisi"
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ratingController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Rating Sesi (Opsional 1.0 - 5.0)",
                    hintText: "4.5",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.star_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed < 1.0 || parsed > 5.0) {
                      return "Rating harus di antara 1.0 sampai 5.0";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Tanggal Bermain",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    child: Text(formattedDate),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<GameLogBloc, GameLogState>(
                  builder: (context, state) {
                    final isLoading = switch (state) {
                      GameLogLoading() => true,
                      GameLogInitial() ||
                      GameLogSuccess() ||
                      GameLogFailure() => false,
                    };

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEditing ? "Perbarui Log" : "Simpan Log"),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

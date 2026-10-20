import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nic_backlog/data/models/game_log_model.dart';
import 'package:nic_backlog/logic/game_log/game_log_bloc.dart';
import 'package:nic_backlog/logic/game_log/game_log_event.dart';
import 'package:nic_backlog/logic/game_log/game_log_state.dart';
import 'package:nic_backlog/utils/app_theme.dart';

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
          title: const Text("HAPUS LOG"),
          content: Text('Apakah Anda yakin ingin menghapus log "${log.title}"?'),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text("BATAL"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 2),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text("HAPUS"),
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
        title: Text(isEditing ? "EDIT JURNAL" : "TAMBAH JURNAL"),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.secondary),
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
                  backgroundColor: AppColors.error,
                ),
              );
            case GameLogSuccess():
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEditing
                        ? "JURNAL BERHASIL DIPERBARUI"
                        : "JURNAL BERHASIL DITAMBAHKAN",
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "SESSION LOG ENTRY",
                  style: AppTextStyles.overline,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "JUDUL LOG / AKTIVITAS",
                    hintText: "Misal: Selesai Chapter 1 / Tamat",
                    prefixIcon: Icon(Icons.title, size: 18),
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
                    labelText: "CATATAN GAMEPLAY",
                    hintText:
                        "Tulis progres, impresi cerita, atau build karakter...",
                    prefixIcon: Icon(Icons.notes, size: 18),
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
                    labelText: "RATING SESI (OPSIONAL 1.0 - 5.0)",
                    hintText: "4.5",
                    prefixIcon: Icon(Icons.star_outline, size: 18),
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
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "TANGGAL BERMAIN",
                      prefixIcon: Icon(Icons.calendar_today, size: 18),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    child: Text(
                      formattedDate,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
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

                    return SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.tertiary,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(isEditing ? "PERBARUI LOG" : "SIMPAN LOG"),
                      ),
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

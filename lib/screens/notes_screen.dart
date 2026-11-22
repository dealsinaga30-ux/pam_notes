import 'package:flutter/material.dart';
import '../services/notes_repository.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _repo = NotesRepository();
  late final _notesStream = _repo.watch();

  Future<void> _showAddDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => _AddNoteDialog(repo: _repo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _notesStream,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Belum ada catatan'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              return ListTile(
                title: Text(d['title'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _repo.delete(d.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddNoteDialog extends StatefulWidget {
  final NotesRepository repo;

  const _AddNoteDialog({required this.repo});

  @override
  State<_AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<_AddNoteDialog> {
  final _titleController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      await widget.repo.add(title);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Catatan'),
      content: TextField(
        controller: _titleController,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Judul Catatan',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: Text(_isSaving ? 'Menyimpan...' : 'Simpan'),
        ),
      ],
    );
  }
}

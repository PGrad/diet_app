import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/journal_entry.dart';

class JournalScreen extends StatefulWidget {
  final String type;
  final JournalEntry? existingEntry;

  const JournalScreen({super.key, required this.type, this.existingEntry});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late final TextEditingController _controller;
  final _db = DatabaseHelper();
  bool _saving = false;

  bool get _isEditing => widget.existingEntry != null;

  String get _title =>
      widget.type == 'food' ? 'Food Journal' : 'Symptoms Journal';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.existingEntry?.content ?? '',
    );
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _saving = true);

    if (_isEditing) {
      await _db.updateEntry(widget.existingEntry!.copyWith(content: text));
    } else {
      await _db.insertEntry(JournalEntry(
        type: widget.type,
        content: text,
        createdAt: DateTime.now().toIso8601String(),
      ));
    }

    setState(() => _saving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Entry updated!' : 'Entry saved!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entryDate = widget.existingEntry != null
        ? DateTime.parse(widget.existingEntry!.createdAt)
        : DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(entryDate),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: widget.type == 'food'
                      ? 'What did you eat today?'
                      : 'How are you feeling?',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _isEditing ? 'Update' : 'Submit',
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

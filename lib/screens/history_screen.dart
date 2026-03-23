import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/journal_entry.dart';

class HistoryScreen extends StatefulWidget {
  final String type;

  const HistoryScreen({super.key, required this.type});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<JournalEntry>> _entries;

  String get _title =>
      widget.type == 'food' ? 'Food History' : 'Symptoms History';

  @override
  void initState() {
    super.initState();
    _entries = DatabaseHelper().getEntriesByType(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: FutureBuilder<List<JournalEntry>>(
        future: _entries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return const Center(child: Text('No entries yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final entry = entries[index];
              final date = DateTime.parse(entry.createdAt);
              return ListTile(
                title: Text(
                  entry.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  DateFormat('MMM d, yyyy – h:mm a').format(date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () => _showFullEntry(context, entry),
              );
            },
          );
        },
      ),
    );
  }

  void _showFullEntry(BuildContext context, JournalEntry entry) {
    final date = DateTime.parse(entry.createdAt);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(DateFormat('MMM d, yyyy – h:mm a').format(date)),
        content: SingleChildScrollView(child: Text(entry.content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

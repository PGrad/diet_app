import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/journal_entry.dart';
import 'journal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseHelper();
  List<JournalEntry> _foodEntries = [];
  List<JournalEntry> _symptomEntries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final food = await _db.getEntriesByType('food');
    final symptoms = await _db.getEntriesByType('symptoms');
    setState(() {
      _foodEntries = food;
      _symptomEntries = symptoms;
    });
  }

  Future<void> _onAddTapped(String type) async {
    final today = await _db.getTodayEntryByType(type);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JournalScreen(type: type, existingEntry: today),
      ),
    );
    _loadEntries();
  }

  Future<void> _onEntryTapped(JournalEntry entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JournalScreen(type: entry.type, existingEntry: entry),
      ),
    );
    _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Journal'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          _JournalRow(
            label: 'Food Journal',
            color: Colors.green,
            icon: Icons.restaurant,
            entries: _foodEntries,
            onAddTapped: () => _onAddTapped('food'),
            onEntryTapped: _onEntryTapped,
          ),
          const SizedBox(height: 32),
          _JournalRow(
            label: 'Symptoms Journal',
            color: Colors.orange,
            icon: Icons.healing,
            entries: _symptomEntries,
            onAddTapped: () => _onAddTapped('symptoms'),
            onEntryTapped: _onEntryTapped,
          ),
        ],
      ),
    );
  }
}

class _JournalRow extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final List<JournalEntry> entries;
  final VoidCallback onAddTapped;
  final void Function(JournalEntry) onEntryTapped;

  const _JournalRow({
    required this.label,
    required this.color,
    required this.icon,
    required this.entries,
    required this.onAddTapped,
    required this.onEntryTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: entries.length + 1, // +1 for the Add button
            itemBuilder: (context, index) {
              if (index == entries.length) {
                return _AddCard(color: color, onTap: onAddTapped);
              }
              return _EntryCard(
                entry: entries[index],
                color: color,
                onTap: () => onEntryTapped(entries[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  final JournalEntry entry;
  final Color color;
  final VoidCallback onTap;

  const _EntryCard({
    required this.entry,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(entry.createdAt);
    final isToday = DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isToday ? 'Today' : DateFormat('MMM d').format(date),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 13,
                  ),
                ),
                if (isToday) ...[
                  const Spacer(),
                  Icon(Icons.edit, size: 13, color: color),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                entry.content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCard extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _AddCard({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: color, size: 32),
            const SizedBox(height: 6),
            Text(
              'New Entry',
              style: TextStyle(color: color, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

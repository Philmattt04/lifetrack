import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/lifetrack_provider.dart';
import '../models/journal_entry.dart';
import 'add_journal_screen.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LifeTrackProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Group entries by month
    final groups = <String, List<JournalEntry>>{};
    for (final e in p.journal) {
      final key = DateFormat('MMMM yyyy').format(e.date);
      (groups[key] ??= []).add(e);
    }

    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Journal', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111827))),
              const SizedBox(height: 2),
              Text('${p.journal.length} ${p.journal.length == 1 ? 'entry' : 'entries'}',
                  style: TextStyle(fontSize: 12,
                      color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af))),
            ])),
            // Mood trend (last 7 days)
            if (p.journal.isNotEmpty)
              _MoodStreak(entries: p.journal.take(7).toList()),
          ]),
        ),

        Expanded(
          child: p.journal.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('📔', style: TextStyle(fontSize: 40,
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFd1d5db))),
                  const SizedBox(height: 12),
                  Text('No entries yet', style: TextStyle(fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF4b5563) : const Color(0xFF9ca3af))),
                  const SizedBox(height: 4),
                  Text('Tap + to write today\'s entry', style: TextStyle(fontSize: 12,
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFd1d5db))),
                ]))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  children: [
                    for (final entry in groups.entries) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 4),
                        child: Text(entry.key, style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8,
                          color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af),
                        )),
                      ),
                      ...entry.value.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _EntryCard(
                          entry: e, isDark: isDark,
                          onEdit: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => AddJournalScreen(entry: e))),
                          onDelete: () => p.deleteJournalEntry(e.id),
                        ),
                      )),
                    ],
                  ],
                ),
        ),
      ]),
    );
  }
}

class _MoodStreak extends StatelessWidget {
  final List<JournalEntry> entries;
  const _MoodStreak({required this.entries});

  @override
  Widget build(BuildContext context) => Row(
    children: entries.reversed.map((e) => Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(JournalEntry.moodEmoji(e.mood),
          style: const TextStyle(fontSize: 16)),
    )).toList(),
  );
}

class _EntryCard extends StatelessWidget {
  final JournalEntry entry;
  final bool isDark;
  final VoidCallback onEdit, onDelete;
  const _EntryCard({required this.entry, required this.isDark,
      required this.onEdit, required this.onDelete});

  static const _moodColors = [
    Color(0xFFef4444), Color(0xFFf97316), Color(0xFFf59e0b),
    Color(0xFF22c55e), Color(0xFF10b981),
  ];

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onEdit,
    onLongPress: () => _showOptions(context),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFe5e7eb),
        ),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: _moodColors[entry.mood - 1].withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text(JournalEntry.moodEmoji(entry.mood),
              style: const TextStyle(fontSize: 20))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(DateFormat('EEEE, MMM d').format(entry.date), style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF9ca3af) : const Color(0xFF6b7280),
            )),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _moodColors[entry.mood - 1].withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(JournalEntry.moodLabel(entry.mood), style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600,
                color: _moodColors[entry.mood - 1],
              )),
            ),
          ]),
          const SizedBox(height: 4),
          Text(
            entry.content.length > 120 ? '${entry.content.substring(0, 120)}…' : entry.content,
            style: TextStyle(fontSize: 13, height: 1.5,
                color: isDark ? const Color(0xFFd1d5db) : const Color(0xFF374151)),
          ),
        ])),
      ]),
    ),
  );

  void _showOptions(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Edit'),
            onTap: () { Navigator.pop(ctx); onEdit(); }),
        ListTile(
          leading: const Icon(Icons.delete_outline, color: Color(0xFFef4444)),
          title: const Text('Delete', style: TextStyle(color: Color(0xFFef4444))),
          onTap: () { Navigator.pop(ctx); onDelete(); },
        ),
      ])),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/journal_entry.dart';
import '../providers/lifetrack_provider.dart';

class AddJournalScreen extends StatefulWidget {
  final JournalEntry? entry;
  const AddJournalScreen({super.key, this.entry});

  @override
  State<AddJournalScreen> createState() => _AddJournalScreenState();
}

class _AddJournalScreenState extends State<AddJournalScreen> {
  final _contentCtrl = TextEditingController();
  int _mood = 3;
  DateTime _date = DateTime.now();

  bool get _isEditing => widget.entry != null;

  static const _moods = [
    (emoji: '😢', label: 'Rough'),
    (emoji: '😕', label: 'Low'),
    (emoji: '😐', label: 'Okay'),
    (emoji: '🙂', label: 'Good'),
    (emoji: '😄', label: 'Great'),
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _contentCtrl.text = widget.entry!.content;
      _mood = widget.entry!.mood;
      _date = widget.entry!.date;
    }
  }

  @override
  void dispose() { _contentCtrl.dispose(); super.dispose(); }

  void _save() {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) return;
    final p = context.read<LifeTrackProvider>();
    if (_isEditing) {
      p.updateJournalEntry(widget.entry!.copyWith(content: content, mood: _mood));
    } else {
      p.addJournalEntry(p.buildJournalEntry(content: content, mood: _mood, date: _date));
    }
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Entry' : 'New Entry'),
        actions: [TextButton(
          onPressed: _save,
          child: const Text('Save', style: TextStyle(color: Color(0xFFf59e0b), fontWeight: FontWeight.w600)),
        )],
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        // Mood selector
        _Label(text: 'HOW ARE YOU FEELING?', isDark: isDark),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            final sel = _mood == i + 1;
            return GestureDetector(
              onTap: () => setState(() => _mood = i + 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: sel
                      ? const Color(0xFFf59e0b).withValues(alpha: 0.15)
                      : isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: sel
                      ? Border.all(color: const Color(0xFFf59e0b).withValues(alpha: 0.6))
                      : null,
                ),
                child: Column(children: [
                  Text(_moods[i].emoji, style: TextStyle(fontSize: sel ? 28 : 22)),
                  const SizedBox(height: 4),
                  Text(_moods[i].label, style: TextStyle(
                    fontSize: 10, fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                    color: sel ? const Color(0xFFf59e0b)
                        : isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af),
                  )),
                ]),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        // Date
        _Label(text: 'DATE', isDark: isDark),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              Icon(Icons.calendar_today_rounded, size: 16,
                  color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af)),
              const SizedBox(width: 10),
              Text('${_date.day}/${_date.month}/${_date.year}', style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF111827),
              )),
            ]),
          ),
        ),
        const SizedBox(height: 24),

        // Content
        _Label(text: 'WRITE YOUR THOUGHTS', isDark: isDark),
        const SizedBox(height: 8),
        TextField(
          controller: _contentCtrl,
          autofocus: !_isEditing,
          maxLines: 10,
          minLines: 6,
          decoration: InputDecoration(
            hintText: 'What\'s on your mind today?',
            hintStyle: TextStyle(
              color: isDark ? const Color(0xFF4b5563) : const Color(0xFF9ca3af),
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ]),
    );
  }
}

class _Label extends StatelessWidget {
  final String text; final bool isDark;
  const _Label({required this.text, required this.isDark});
  @override
  Widget build(BuildContext context) => Text(text, style: TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8,
    color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af),
  ));
}

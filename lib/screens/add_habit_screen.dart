import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/lifetrack_provider.dart';

class AddHabitScreen extends StatefulWidget {
  final Habit? habit;
  const AddHabitScreen({super.key, this.habit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _nameCtrl = TextEditingController();
  String _emoji = '💪';
  Color _color = kHabitColors[0];
  HabitFrequency _frequency = HabitFrequency.daily;
  List<int> _targetDays = [1, 2, 3, 4, 5, 6, 7];

  bool get _isEditing => widget.habit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final h = widget.habit!;
      _nameCtrl.text = h.name;
      _emoji = h.emoji;
      _color = h.color;
      _frequency = h.frequency;
      _targetDays = List.from(h.targetDays);
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final p = context.read<LifeTrackProvider>();
    if (_isEditing) {
      p.updateHabit(widget.habit!.copyWith(
        name: name, emoji: _emoji, color: _color,
        frequency: _frequency, targetDays: _targetDays,
      ));
    } else {
      p.addHabit(p.buildHabit(
        name: name, emoji: _emoji, color: _color,
        frequency: _frequency, targetDays: _targetDays,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Habit' : 'New Habit'),
        actions: [TextButton(
          onPressed: _save,
          child: const Text('Save', style: TextStyle(color: Color(0xFF6366f1), fontWeight: FontWeight.w600)),
        )],
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        _Section(label: 'Name', child: TextField(
          controller: _nameCtrl, autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. Morning run',
            filled: true,
            fillColor: isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF3F4F6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        )),
        const SizedBox(height: 20),
        _Section(label: 'Icon', child: Wrap(
          spacing: 10, runSpacing: 10,
          children: kHabitEmojis.map((e) {
            final sel = e == _emoji;
            return GestureDetector(
              onTap: () => setState(() => _emoji = e),
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: sel ? _color.withValues(alpha: 0.2)
                      : isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                  border: sel ? Border.all(color: _color, width: 2) : null,
                ),
                child: Center(child: Text(e, style: const TextStyle(fontSize: 20))),
              ),
            );
          }).toList(),
        )),
        const SizedBox(height: 20),
        _Section(label: 'Color', child: Row(
          children: kHabitColors.map((c) {
            final sel = c.value == _color.value;
            return GestureDetector(
              onTap: () => setState(() => _color = c),
              child: Container(
                width: 32, height: 32,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: c, shape: BoxShape.circle,
                  border: sel ? Border.all(color: isDark ? Colors.white : Colors.black, width: 2.5) : null,
                ),
                child: sel ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
              ),
            );
          }).toList(),
        )),
        const SizedBox(height: 20),
        _Section(label: 'Frequency', child: Column(children: [
          _FreqOpt(label: 'Every day', sel: _frequency == HabitFrequency.daily, isDark: isDark,
              onTap: () => setState(() { _frequency = HabitFrequency.daily; _targetDays = [1,2,3,4,5,6,7]; })),
          const SizedBox(height: 8),
          _FreqOpt(label: 'Weekdays (Mon–Fri)', sel: _frequency == HabitFrequency.weekdays, isDark: isDark,
              onTap: () => setState(() { _frequency = HabitFrequency.weekdays; _targetDays = [1,2,3,4,5]; })),
          const SizedBox(height: 8),
          _FreqOpt(label: 'Custom days', sel: _frequency == HabitFrequency.custom, isDark: isDark,
              onTap: () => setState(() => _frequency = HabitFrequency.custom)),
          if (_frequency == HabitFrequency.custom) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (i) {
                final day = i + 1;
                final sel = _targetDays.contains(day);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (sel) { if (_targetDays.length > 1) _targetDays.remove(day); }
                    else _targetDays.add(day);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: sel ? _color : isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                      border: sel ? null : Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFe5e7eb),
                      ),
                    ),
                    child: Center(child: Text(
                      ['M','T','W','T','F','S','S'][i],
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : isDark ? const Color(0xFF9ca3af) : const Color(0xFF6b7280)),
                    )),
                  ),
                );
              }),
            ),
          ],
        ])),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String label; final Widget child;
  const _Section({required this.label, required this.child});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
          letterSpacing: 0.8, color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af))),
      const SizedBox(height: 8),
      child,
    ]);
  }
}

class _FreqOpt extends StatelessWidget {
  final String label; final bool sel, isDark; final VoidCallback onTap;
  const _FreqOpt({required this.label, required this.sel, required this.isDark, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: sel ? const Color(0xFF6366f1).withValues(alpha: 0.1)
            : isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: sel ? Border.all(color: const Color(0xFF6366f1).withValues(alpha: 0.5)) : null,
      ),
      child: Row(children: [
        Expanded(child: Text(label, style: TextStyle(
          color: sel ? const Color(0xFF818cf8) : isDark ? const Color(0xFFd1d5db) : const Color(0xFF374151),
        ))),
        if (sel) const Icon(Icons.check_rounded, size: 18, color: Color(0xFF818cf8)),
      ]),
    ),
  );
}

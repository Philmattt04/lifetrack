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
  HabitTimeOfDay _timeOfDay = HabitTimeOfDay.anyTime;
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
      _timeOfDay = h.timeOfDay;
      _targetDays = List.from(h.targetDays);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final p = context.read<LifeTrackProvider>();
    if (_isEditing) {
      p.updateHabit(widget.habit!.copyWith(
        name: name, emoji: _emoji, color: _color,
        frequency: _frequency, targetDays: _targetDays, timeOfDay: _timeOfDay,
      ));
    } else {
      p.addHabit(p.buildHabit(
        name: name, emoji: _emoji, color: _color,
        frequency: _frequency, targetDays: _targetDays, timeOfDay: _timeOfDay,
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
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save',
                style: TextStyle(color: Color(0xFF6366f1), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Name
          _Label(text: 'NAME', isDark: isDark),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            autofocus: !_isEditing,
            decoration: InputDecoration(
              hintText: 'e.g. Morning run',
              hintStyle: TextStyle(
                  color: isDark ? const Color(0xFF4b5563) : const Color(0xFF9ca3af)),
              filled: true,
              fillColor: isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),

          // Icon
          _Label(text: 'ICON', isDark: isDark),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: kHabitEmojis.map((e) {
              final sel = e == _emoji;
              return GestureDetector(
                onTap: () => setState(() => _emoji = e),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: sel
                        ? _color.withValues(alpha: 0.18)
                        : isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: sel ? Border.all(color: _color, width: 2) : null,
                  ),
                  child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Color
          _Label(text: 'COLOR', isDark: isDark),
          const SizedBox(height: 10),
          Row(
            children: kHabitColors.map((c) {
              final sel = c.value == _color.value;
              return GestureDetector(
                onTap: () => setState(() => _color = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: sel
                        ? Border.all(
                            color: isDark ? Colors.white : Colors.black,
                            width: 2.5)
                        : null,
                  ),
                  child: sel
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Frequency dropdown
          _Label(text: 'FREQUENCY', isDark: isDark),
          const SizedBox(height: 8),
          _Dropdown<HabitFrequency>(
            value: _frequency,
            isDark: isDark,
            items: const [
              DropdownMenuItem(value: HabitFrequency.daily, child: Text('Every day')),
              DropdownMenuItem(value: HabitFrequency.weekdays, child: Text('Weekdays (Mon–Fri)')),
              DropdownMenuItem(value: HabitFrequency.custom, child: Text('Custom days')),
            ],
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _frequency = v;
                if (v == HabitFrequency.daily) _targetDays = [1, 2, 3, 4, 5, 6, 7];
                if (v == HabitFrequency.weekdays) _targetDays = [1, 2, 3, 4, 5];
              });
            },
          ),

          // Custom day chips — only shown when custom is selected
          if (_frequency == HabitFrequency.custom) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (i) {
                final day = i + 1;
                final sel = _targetDays.contains(day);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (sel) {
                      if (_targetDays.length > 1) _targetDays.remove(day);
                    } else {
                      _targetDays.add(day);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: sel
                          ? _color
                          : isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                      border: sel
                          ? null
                          : Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : const Color(0xFFe5e7eb)),
                    ),
                    child: Center(
                      child: Text(
                        ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel
                              ? Colors.white
                              : isDark
                                  ? const Color(0xFF9ca3af)
                                  : const Color(0xFF6b7280),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
          const SizedBox(height: 24),

          // Time of day dropdown
          _Label(text: 'TIME OF DAY', isDark: isDark),
          const SizedBox(height: 8),
          _Dropdown<HabitTimeOfDay>(
            value: _timeOfDay,
            isDark: isDark,
            items: HabitTimeOfDay.values
                .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                .toList(),
            onChanged: (v) { if (v != null) setState(() => _timeOfDay = v); },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final bool isDark;
  const _Label({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af),
        ),
      );
}

class _Dropdown<T> extends StatelessWidget {
  final T value;
  final bool isDark;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  const _Dropdown({
    required this.value,
    required this.isDark,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af),
        ),
        dropdownColor: isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF3F4F6),
        style: TextStyle(
          fontSize: 15,
          color: isDark ? Colors.white : const Color(0xFF111827),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}

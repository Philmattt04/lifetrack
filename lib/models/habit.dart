import 'dart:convert';
import 'package:flutter/material.dart';

enum HabitFrequency { daily, weekdays, custom }

class Habit {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final HabitFrequency frequency;
  final List<int> targetDays;
  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.frequency,
    required this.targetDays,
    required this.createdAt,
  });

  bool isScheduledOn(DateTime date) {
    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekdays:
        return date.weekday <= 5;
      case HabitFrequency.custom:
        return targetDays.contains(date.weekday);
    }
  }

  Habit copyWith({
    String? name, String? emoji, Color? color,
    HabitFrequency? frequency, List<int>? targetDays,
  }) =>
      Habit(
        id: id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        color: color ?? this.color,
        frequency: frequency ?? this.frequency,
        targetDays: targetDays ?? this.targetDays,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'color': color.value,
        'frequency': frequency.name,
        'target_days': jsonEncode(targetDays),
        'created_at': createdAt.toIso8601String(),
      };

  factory Habit.fromMap(Map<String, dynamic> m) => Habit(
        id: m['id'] as String,
        name: m['name'] as String,
        emoji: m['emoji'] as String,
        color: Color(m['color'] as int),
        frequency: HabitFrequency.values.firstWhere(
          (f) => f.name == m['frequency'],
          orElse: () => HabitFrequency.daily,
        ),
        targetDays: (jsonDecode(m['target_days'] as String) as List)
            .map((e) => e as int)
            .toList(),
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}

const kHabitEmojis = [
  '💪', '🏃', '🧘', '📚', '💧', '🥗', '🌙', '✍️',
  '🎯', '🎸', '🧹', '💊', '🛌', '🚴', '🏋️', '🍎',
  '☀️', '🧠', '💻', '🎨', '🌿', '🐕', '💰', '🙏',
];

const kHabitColors = [
  Color(0xFF22c55e),
  Color(0xFF3b82f6),
  Color(0xFFf59e0b),
  Color(0xFFef4444),
  Color(0xFF8b5cf6),
  Color(0xFF06b6d4),
  Color(0xFFf97316),
  Color(0xFFec4899),
];

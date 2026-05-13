class HabitLog {
  final String id;
  final String habitId;
  final String date;
  final bool completed;

  const HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completed,
  });

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() => {
        'id': id,
        'habit_id': habitId,
        'date': date,
        'completed': completed ? 1 : 0,
      };

  factory HabitLog.fromMap(Map<String, dynamic> m) => HabitLog(
        id: m['id'] as String,
        habitId: m['habit_id'] as String,
        date: m['date'] as String,
        completed: (m['completed'] as int) == 1,
      );
}

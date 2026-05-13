class JournalEntry {
  final String id;
  final DateTime date;
  final String content;
  final int mood; // 1–5

  const JournalEntry({
    required this.id,
    required this.date,
    required this.content,
    required this.mood,
  });

  JournalEntry copyWith({String? content, int? mood}) => JournalEntry(
        id: id,
        date: date,
        content: content ?? this.content,
        mood: mood ?? this.mood,
      );

  static String moodEmoji(int mood) => switch (mood) {
        1 => '😢',
        2 => '😕',
        3 => '😐',
        4 => '🙂',
        _ => '😄',
      };

  static String moodLabel(int mood) => switch (mood) {
        1 => 'Rough',
        2 => 'Low',
        3 => 'Okay',
        4 => 'Good',
        _ => 'Great',
      };

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'content': content,
        'mood': mood,
      };

  factory JournalEntry.fromMap(Map<String, dynamic> m) => JournalEntry(
        id: m['id'] as String,
        date: DateTime.parse(m['date'] as String),
        content: m['content'] as String,
        mood: m['mood'] as int,
      );
}

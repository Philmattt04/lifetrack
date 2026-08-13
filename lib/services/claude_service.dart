import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/journal_entry.dart';
import '../models/transaction.dart';

class ClaudeService {
  // Updated by deploy.sh after Terraform outputs the API Gateway URL
  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://jmx93lnv9f.execute-api.us-east-1.amazonaws.com//insights',
  );

  static final _currFmt = NumberFormat.currency(symbol: '\$');

  static Future<String> weeklyInsights({
    required List<Habit> habits,
    required Map<String, List<HabitLog>> logsByHabit,
    required List<JournalEntry> journal,
    required List<Transaction> transactions,
  }) async {
    final data = _buildContext(habits, logsByHabit, journal, transactions);
    return _call(type: 'insights', data: data);
  }

  static Future<String> chat({
    required String question,
    required List<Habit> habits,
    required Map<String, List<HabitLog>> logsByHabit,
    required List<JournalEntry> journal,
    required List<Transaction> transactions,
    required List<Map<String, String>> history,
  }) async {
    final data = _buildContext(habits, logsByHabit, journal, transactions);
    return _call(type: 'chat', data: data, question: question, history: history);
  }

  static Future<String> _call({
    required String type,
    required String data,
    String? question,
    List<Map<String, String>>? history,
  }) async {
    final res = await http
        .post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'type': type,
            'context': data,
            if (question != null) 'question': question,
            if (history != null) 'history': history,
          }),
        )
        .timeout(const Duration(seconds: 60));

    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as Map<String, dynamic>)['content'] as String;
    }
    throw Exception('AI request failed: ${res.statusCode}');
  }

  static String _buildContext(
    List<Habit> habits,
    Map<String, List<HabitLog>> logsByHabit,
    List<JournalEntry> journal,
    List<Transaction> transactions,
  ) {
    final now = DateTime.now();
    final buf = StringBuffer();

    // ── Habits (last 7 days) ──
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    buf.writeln('=== HABITS (last 7 days) ===');
    for (final h in habits) {
      final logs = logsByHabit[h.id] ?? [];
      final logMap = {for (final l in logs) l.date: l.completed};
      final row = days.map((d) {
        if (!h.isScheduledOn(d)) return '-';
        return (logMap[HabitLog.dateKey(d)] ?? false) ? '✓' : '✗';
      }).join(' ');
      final scheduled = days.where((d) => h.isScheduledOn(d)).length;
      final done = days.where((d) {
        return h.isScheduledOn(d) && (logMap[HabitLog.dateKey(d)] ?? false);
      }).length;
      buf.writeln('${h.emoji} ${h.name}: $row ($done/$scheduled)');
    }

    // ── Journal / Mood (last 7 entries) ──
    buf.writeln('\n=== JOURNAL & MOOD (last 7 entries) ===');
    final recent = journal.take(7).toList();
    if (recent.isEmpty) {
      buf.writeln('No journal entries yet.');
    } else {
      for (final e in recent) {
        final dateStr = DateFormat('MMM d').format(e.date);
        final snippet = e.content.length > 100 ? '${e.content.substring(0, 100)}…' : e.content;
        buf.writeln('$dateStr ${JournalEntry.moodEmoji(e.mood)} ${JournalEntry.moodLabel(e.mood)}: $snippet');
      }
      final avgMood = recent.map((e) => e.mood).reduce((a, b) => a + b) / recent.length;
      buf.writeln('Average mood: ${avgMood.toStringAsFixed(1)}/5');
    }

    // ── Budget (current month) ──
    final monthStart = DateTime(now.year, now.month, 1);
    final monthTxns = transactions.where((t) => !t.date.isBefore(monthStart)).toList();
    final income = monthTxns.where((t) => t.type == TransactionType.income).fold(0.0, (s, t) => s + t.amount);
    final expenses = monthTxns.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);
    buf.writeln('\n=== BUDGET (${DateFormat('MMMM yyyy').format(now)}) ===');
    buf.writeln('Income: ${_currFmt.format(income)}  Expenses: ${_currFmt.format(expenses)}  Balance: ${_currFmt.format(income - expenses)}');
    final byCategory = <BudgetCategory, double>{};
    for (final t in monthTxns.where((t) => t.type == TransactionType.expense)) {
      byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
    }
    for (final e in byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value))) {
      buf.writeln('  ${e.key.label}: ${_currFmt.format(e.value)}');
    }

    return buf.toString();
  }
}

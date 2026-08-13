import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/journal_entry.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../services/claude_service.dart';
import '../services/demo_data.dart';

class LifeTrackProvider extends ChangeNotifier {
  final _db = StorageService.instance;
  final _uuid = const Uuid();

  // ── State ────────────────────────────────────────────────────────────────

  List<Habit> _habits = [];
  Map<String, bool> _todayCompletions = {};
  List<JournalEntry> _journal = [];
  List<Transaction> _transactions = [];
  bool _loading = true;

  String _weeklyInsights = '';
  bool _insightsLoading = false;
  final List<Map<String, String>> _chatHistory = [];
  bool _chatLoading = false;

  // ── Getters ──────────────────────────────────────────────────────────────

  List<Habit> get habits => _habits;
  Map<String, bool> get todayCompletions => _todayCompletions;
  List<JournalEntry> get journal => _journal;
  List<Transaction> get transactions => _transactions;
  bool get loading => _loading;
  String get weeklyInsights => _weeklyInsights;
  bool get insightsLoading => _insightsLoading;
  List<Map<String, String>> get chatHistory => _chatHistory;
  bool get chatLoading => _chatLoading;

  String get todayKey => HabitLog.dateKey(DateTime.now());

  List<Habit> get todayHabits =>
      _habits.where((h) => h.isScheduledOn(DateTime.now())).toList();

  int get todayCompleted =>
      todayHabits.where((h) => _todayCompletions[h.id] == true).length;

  double get todayHabitRate =>
      todayHabits.isEmpty ? 0 : todayCompleted / todayHabits.length;

  JournalEntry? get todayEntry {
    final key = todayKey;
    try {
      return _journal.firstWhere(
        (e) => HabitLog.dateKey(e.date) == key,
      );
    } catch (_) {
      return null;
    }
  }

  List<Transaction> get thisMonthTransactions {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return _transactions.where((t) => !t.date.isBefore(start)).toList();
  }

  double get monthBalance {
    final income = thisMonthTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final expenses = thisMonthTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);
    return income - expenses;
  }

  double get monthExpenses => thisMonthTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (s, t) => s + t.amount);

  double get monthIncome => thisMonthTransactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (s, t) => s + t.amount);

  Map<BudgetCategory, double> get expensesByCategory {
    final map = <BudgetCategory, double>{};
    for (final t in thisMonthTransactions.where((t) => t.type == TransactionType.expense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  // ── Load ─────────────────────────────────────────────────────────────────

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _habits = await _db.getHabits();
      if (kIsWeb && _habits.isEmpty) {
        await DemoData.seed();
        _habits = await _db.getHabits();
      }
      final logs = await _db.getLogsForDate(todayKey);
      _todayCompletions = {for (final l in logs) l.habitId: l.completed};
      _journal = await _db.getJournalEntries();
      _transactions = await _db.getTransactions();
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  // ── Habits ────────────────────────────────────────────────────────────────

  Future<void> toggleHabit(String habitId) async {
    final next = !(_todayCompletions[habitId] ?? false);
    _todayCompletions[habitId] = next;
    notifyListeners();
    await _db.upsertLog(HabitLog(
      id: _uuid.v4(), habitId: habitId, date: todayKey, completed: next,
    ));
  }

  Future<void> addHabit(Habit habit) async {
    await _db.insertHabit(habit);
    _habits = await _db.getHabits();
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    await _db.updateHabit(habit);
    _habits = await _db.getHabits();
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    await _db.deleteHabit(id);
    _habits = await _db.getHabits();
    _todayCompletions.remove(id);
    notifyListeners();
  }

  Future<Map<String, bool>> getHabitHistory(String habitId, {int days = 91}) async {
    final logs = await _db.getLogsForHabit(habitId, days: days);
    return {for (final l in logs) l.date: l.completed};
  }

  Habit buildHabit({
    required String name, required String emoji,
    required Color color, required HabitFrequency frequency,
    required List<int> targetDays,
    HabitTimeOfDay timeOfDay = HabitTimeOfDay.anyTime,
  }) =>
      Habit(
        id: _uuid.v4(), name: name, emoji: emoji, color: color,
        frequency: frequency, targetDays: targetDays,
        timeOfDay: timeOfDay, createdAt: DateTime.now(),
      );

  // ── Journal ───────────────────────────────────────────────────────────────

  Future<void> addJournalEntry(JournalEntry entry) async {
    await _db.insertJournal(entry);
    _journal = await _db.getJournalEntries();
    notifyListeners();
  }

  Future<void> updateJournalEntry(JournalEntry entry) async {
    await _db.updateJournal(entry);
    _journal = await _db.getJournalEntries();
    notifyListeners();
  }

  Future<void> deleteJournalEntry(String id) async {
    await _db.deleteJournal(id);
    _journal = await _db.getJournalEntries();
    notifyListeners();
  }

  JournalEntry buildJournalEntry({required String content, required int mood, DateTime? date}) =>
      JournalEntry(id: _uuid.v4(), date: date ?? DateTime.now(), content: content, mood: mood);

  // ── Transactions ──────────────────────────────────────────────────────────

  Future<void> addTransaction(Transaction txn) async {
    await _db.insertTransaction(txn);
    _transactions = await _db.getTransactions();
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction txn) async {
    await _db.updateTransaction(txn);
    _transactions = await _db.getTransactions();
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Transaction buildTransaction({
    required TransactionType type, required double amount,
    required BudgetCategory category, required String note, required DateTime date,
  }) =>
      Transaction(id: _uuid.v4(), type: type, amount: amount,
          category: category, note: note, date: date);

  // ── AI ────────────────────────────────────────────────────────────────────

  Future<void> loadWeeklyInsights() async {
    if (_insightsLoading) return;
    _insightsLoading = true;
    _weeklyInsights = '';
    notifyListeners();
    try {
      final logsByHabit = <String, List<HabitLog>>{};
      for (final h in _habits) {
        logsByHabit[h.id] = await _db.getLogsForHabit(h.id, days: 7);
      }
      _weeklyInsights = await ClaudeService.weeklyInsights(
        habits: _habits,
        logsByHabit: logsByHabit,
        journal: _journal.take(7).toList(),
        transactions: _transactions,
      );
    } catch (_) {
      _weeklyInsights = 'Could not load insights. Check your connection.';
    }
    _insightsLoading = false;
    notifyListeners();
  }

  Future<void> sendChatMessage(String question) async {
    _chatHistory.add({'role': 'user', 'content': question});
    _chatLoading = true;
    notifyListeners();
    try {
      final logsByHabit = <String, List<HabitLog>>{};
      for (final h in _habits) {
        logsByHabit[h.id] = await _db.getLogsForHabit(h.id, days: 30);
      }
      final reply = await ClaudeService.chat(
        question: question,
        habits: _habits,
        logsByHabit: logsByHabit,
        journal: _journal.take(14).toList(),
        transactions: _transactions,
        history: _chatHistory.where((m) => m['role'] == 'assistant').toList(),
      );
      _chatHistory.add({'role': 'assistant', 'content': reply});
    } catch (_) {
      _chatHistory.add({'role': 'assistant', 'content': 'Something went wrong. Please try again.'});
    }
    _chatLoading = false;
    notifyListeners();
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/journal_entry.dart';
import '../models/transaction.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  Future<SharedPreferences> get _p => SharedPreferences.getInstance();

  // ── Habits ──────────────────────────────────────────────────────────────

  Future<List<Habit>> getHabits() async {
    final raw = (await _p).getStringList('lt_habits') ?? [];
    final habits = raw.map((s) => Habit.fromMap(jsonDecode(s))).toList();
    habits.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return habits;
  }

  Future<void> _saveHabits(List<Habit> h) async =>
      (await _p).setStringList('lt_habits', h.map((e) => jsonEncode(e.toMap())).toList());

  Future<void> insertHabit(Habit h) async {
    final list = await getHabits();
    list.add(h);
    await _saveHabits(list);
  }

  Future<void> updateHabit(Habit h) async {
    final list = await getHabits();
    final i = list.indexWhere((e) => e.id == h.id);
    if (i != -1) list[i] = h;
    await _saveHabits(list);
  }

  Future<void> deleteHabit(String id) async {
    final list = await getHabits();
    list.removeWhere((e) => e.id == id);
    await _saveHabits(list);
    final logs = await _getAllLogs();
    logs.removeWhere((l) => l.habitId == id);
    await _saveLogs(logs);
  }

  // ── Habit logs ───────────────────────────────────────────────────────────

  Future<List<HabitLog>> _getAllLogs() async {
    final raw = (await _p).getStringList('lt_habit_logs') ?? [];
    return raw.map((s) => HabitLog.fromMap(jsonDecode(s))).toList();
  }

  Future<void> _saveLogs(List<HabitLog> logs) async =>
      (await _p).setStringList('lt_habit_logs', logs.map((l) => jsonEncode(l.toMap())).toList());

  Future<List<HabitLog>> getLogsForDate(String date) async =>
      (await _getAllLogs()).where((l) => l.date == date).toList();

  Future<List<HabitLog>> getLogsForHabit(String habitId, {int days = 90}) async {
    final since = HabitLog.dateKey(DateTime.now().subtract(Duration(days: days)));
    return (await _getAllLogs())
        .where((l) => l.habitId == habitId && l.date.compareTo(since) >= 0)
        .toList();
  }

  Future<void> upsertLog(HabitLog log) async {
    final logs = await _getAllLogs();
    final i = logs.indexWhere((l) => l.habitId == log.habitId && l.date == log.date);
    if (i != -1) logs[i] = log; else logs.add(log);
    await _saveLogs(logs);
  }

  // ── Journal ──────────────────────────────────────────────────────────────

  Future<List<JournalEntry>> getJournalEntries() async {
    final raw = (await _p).getStringList('lt_journal') ?? [];
    final entries = raw.map((s) => JournalEntry.fromMap(jsonDecode(s))).toList();
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  Future<void> _saveJournal(List<JournalEntry> entries) async =>
      (await _p).setStringList('lt_journal', entries.map((e) => jsonEncode(e.toMap())).toList());

  Future<void> insertJournal(JournalEntry e) async {
    final list = await getJournalEntries();
    list.add(e);
    await _saveJournal(list);
  }

  Future<void> updateJournal(JournalEntry e) async {
    final list = await getJournalEntries();
    final i = list.indexWhere((j) => j.id == e.id);
    if (i != -1) list[i] = e;
    await _saveJournal(list);
  }

  Future<void> deleteJournal(String id) async {
    final list = await getJournalEntries();
    list.removeWhere((e) => e.id == id);
    await _saveJournal(list);
  }

  // ── Transactions ─────────────────────────────────────────────────────────

  Future<List<Transaction>> getTransactions() async {
    final raw = (await _p).getStringList('lt_transactions') ?? [];
    final txns = raw.map((s) => Transaction.fromMap(jsonDecode(s))).toList();
    txns.sort((a, b) => b.date.compareTo(a.date));
    return txns;
  }

  Future<void> _saveTxns(List<Transaction> txns) async =>
      (await _p).setStringList('lt_transactions', txns.map((t) => jsonEncode(t.toMap())).toList());

  Future<void> insertTransaction(Transaction t) async {
    final list = await getTransactions();
    list.add(t);
    await _saveTxns(list);
  }

  Future<void> updateTransaction(Transaction t) async {
    final list = await getTransactions();
    final i = list.indexWhere((e) => e.id == t.id);
    if (i != -1) list[i] = t;
    await _saveTxns(list);
  }

  Future<void> deleteTransaction(String id) async {
    final list = await getTransactions();
    list.removeWhere((t) => t.id == id);
    await _saveTxns(list);
  }
}

import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/journal_entry.dart';
import '../models/transaction.dart';
import 'storage_service.dart';

/// Seeds realistic sample data so first-time visitors to the public web
/// demo see a populated app instead of an empty state. Only ever called
/// when local storage is empty — never touches real user data.
class DemoData {
  static const _uuid = Uuid();

  static Future<void> seed() async {
    final db = StorageService.instance;
    final now = DateTime.now();

    final habits = [
      Habit(id: _uuid.v4(), name: 'Morning run', emoji: '🏃', color: kHabitColors[1],
          frequency: HabitFrequency.daily, targetDays: const [],
          timeOfDay: HabitTimeOfDay.morning, createdAt: now.subtract(const Duration(days: 30))),
      Habit(id: _uuid.v4(), name: 'Read', emoji: '📚', color: kHabitColors[4],
          frequency: HabitFrequency.daily, targetDays: const [],
          timeOfDay: HabitTimeOfDay.evening, createdAt: now.subtract(const Duration(days: 30))),
      Habit(id: _uuid.v4(), name: 'Meditate', emoji: '🧘', color: kHabitColors[2],
          frequency: HabitFrequency.daily, targetDays: const [],
          timeOfDay: HabitTimeOfDay.morning, createdAt: now.subtract(const Duration(days: 30))),
      Habit(id: _uuid.v4(), name: 'Drink water', emoji: '💧', color: kHabitColors[5],
          frequency: HabitFrequency.daily, targetDays: const [],
          createdAt: now.subtract(const Duration(days: 30))),
      Habit(id: _uuid.v4(), name: 'Gym', emoji: '🏋️', color: kHabitColors[3],
          frequency: HabitFrequency.weekdays, targetDays: const [],
          timeOfDay: HabitTimeOfDay.evening, createdAt: now.subtract(const Duration(days: 30))),
    ];
    for (final h in habits) {
      await db.insertHabit(h);
    }

    // 21 days of habit logs with realistic (not perfect) completion patterns.
    final rand = List.generate(habits.length, (i) => 0.55 + i * 0.08);
    for (var d = 0; d < 21; d++) {
      final date = now.subtract(Duration(days: d));
      for (var i = 0; i < habits.length; i++) {
        final h = habits[i];
        if (!h.isScheduledOn(date)) continue;
        final seed = (date.day * 31 + i * 17) % 100 / 100.0;
        final completed = seed < rand[i];
        await db.upsertLog(HabitLog(
          id: _uuid.v4(),
          habitId: h.id,
          date: HabitLog.dateKey(date),
          completed: completed,
        ));
      }
    }

    final journalEntries = [
      (0, 4, "Good energy today. Got the run in before work and it set the tone for everything else."),
      (1, 3, "Busy day, meetings back to back. Skipped the gym but managed to read before bed."),
      (2, 5, "Great mood — closed out a big project and treated myself to dinner out."),
      (4, 2, "Rough night of sleep, felt sluggish all day. Need to reset the routine."),
      (6, 4, "Solid week overall. Meditation is starting to feel like a real habit now."),
      (9, 3, "Okay day, nothing special. Spent a bit too much on takeout again."),
      (13, 4, "Back on track with workouts. Feeling stronger and more consistent."),
    ];
    for (final (daysAgo, mood, content) in journalEntries) {
      await db.insertJournal(JournalEntry(
        id: _uuid.v4(),
        date: now.subtract(Duration(days: daysAgo)),
        content: content,
        mood: mood,
      ));
    }

    final transactions = [
      (0, TransactionType.expense, 12.50, BudgetCategory.food, 'Coffee & lunch'),
      (1, TransactionType.expense, 45.00, BudgetCategory.transport, 'Gas'),
      (2, TransactionType.expense, 89.99, BudgetCategory.entertainment, 'Concert tickets'),
      (3, TransactionType.income, 3200.00, BudgetCategory.other, 'Paycheck'),
      (4, TransactionType.expense, 1400.00, BudgetCategory.housing, 'Rent'),
      (5, TransactionType.expense, 62.30, BudgetCategory.food, 'Groceries'),
      (7, TransactionType.expense, 28.00, BudgetCategory.health, 'Pharmacy'),
      (9, TransactionType.expense, 150.00, BudgetCategory.savings, 'Transfer to savings'),
      (11, TransactionType.expense, 34.75, BudgetCategory.food, 'Dinner out'),
      (14, TransactionType.expense, 55.00, BudgetCategory.entertainment, 'Streaming + subscriptions'),
    ];
    for (final (daysAgo, type, amount, category, note) in transactions) {
      await db.insertTransaction(Transaction(
        id: _uuid.v4(),
        type: type,
        amount: amount,
        category: category,
        note: note,
        date: now.subtract(Duration(days: daysAgo)),
      ));
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/lifetrack_provider.dart';
import '../models/habit.dart';
import '../models/journal_entry.dart';
import '../models/transaction.dart';
import 'add_habit_screen.dart';
import 'add_journal_screen.dart';
import 'add_transaction_screen.dart';

class AllDataScreen extends StatelessWidget {
  const AllDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Text(
                'All Data',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TabBar(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              labelColor: isDark ? Colors.white : const Color(0xFF111827),
              unselectedLabelColor:
                  isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af),
              labelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              indicatorColor: const Color(0xFF6366f1),
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : const Color(0xFFe5e7eb),
              tabs: const [
                Tab(text: 'Habits'),
                Tab(text: 'Journal'),
                Tab(text: 'Transactions'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _HabitsTab(isDark: isDark),
                  _JournalTab(isDark: isDark),
                  _TransactionsTab(isDark: isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Habits tab
// ─────────────────────────────────────────────────────────────────────────────

class _HabitsTab extends StatelessWidget {
  final bool isDark;
  const _HabitsTab({required this.isDark});

  static const _freqLabel = {
    HabitFrequency.daily: 'Every day',
    HabitFrequency.weekdays: 'Weekdays',
    HabitFrequency.custom: 'Custom',
  };

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<LifeTrackProvider>().habits;

    if (habits.isEmpty) {
      return _Empty(
          emoji: '✅', message: 'No habits yet', isDark: isDark);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      itemCount: habits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final h = habits[i];
        return GestureDetector(
          onLongPress: () => _showOptions(ctx, h, context),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : const Color(0xFFe5e7eb),
              ),
            ),
            child: Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: h.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Center(child: Text(h.emoji, style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? Colors.white : const Color(0xFF111827),
                          )),
                      const SizedBox(height: 3),
                      Row(children: [
                        _Chip(
                          label: _freqLabel[h.frequency] ?? 'Daily',
                          color: h.color,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 6),
                        _Chip(
                          label: h.timeOfDay.label,
                          color: const Color(0xFF6366f1),
                          isDark: isDark,
                        ),
                      ]),
                    ]),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: h.color, shape: BoxShape.circle),
              ),
            ]),
          ),
        );
      },
    );
  }

  void _showOptions(BuildContext listCtx, Habit h, BuildContext rootCtx) {
    final p = rootCtx.read<LifeTrackProvider>();
    showModalBottomSheet(
      context: listCtx,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(listCtx);
              Navigator.push(listCtx,
                  MaterialPageRoute(builder: (_) => AddHabitScreen(habit: h)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Color(0xFFef4444)),
            title:
                const Text('Delete', style: TextStyle(color: Color(0xFFef4444))),
            onTap: () {
              Navigator.pop(listCtx);
              p.deleteHabit(h.id);
            },
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Journal tab
// ─────────────────────────────────────────────────────────────────────────────

class _JournalTab extends StatelessWidget {
  final bool isDark;
  const _JournalTab({required this.isDark});

  static const _moodColors = [
    Color(0xFFef4444),
    Color(0xFFf97316),
    Color(0xFFf59e0b),
    Color(0xFF22c55e),
    Color(0xFF10b981),
  ];

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<LifeTrackProvider>().journal;

    if (entries.isEmpty) {
      return _Empty(emoji: '📔', message: 'No journal entries yet', isDark: isDark);
    }

    // Group by month
    final groups = <String, List<JournalEntry>>{};
    for (final e in entries) {
      final key = DateFormat('MMMM yyyy').format(e.date);
      (groups[key] ??= []).add(e);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Text(entry.key,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: isDark
                      ? const Color(0xFF6b7280)
                      : const Color(0xFF9ca3af),
                )),
          ),
          ...entry.value.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => AddJournalScreen(entry: e))),
                  onLongPress: () => _showOptions(context, e),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1a1a2e)
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.07)
                            : const Color(0xFFe5e7eb),
                      ),
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _moodColors[e.mood - 1]
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                                child: Text(JournalEntry.moodEmoji(e.mood),
                                    style: const TextStyle(fontSize: 20))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Text(
                                        DateFormat('EEE, MMM d').format(e.date),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? const Color(0xFF9ca3af)
                                              : const Color(0xFF6b7280),
                                        )),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _moodColors[e.mood - 1]
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                          JournalEntry.moodLabel(e.mood),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: _moodColors[e.mood - 1],
                                          )),
                                    ),
                                  ]),
                                  const SizedBox(height: 4),
                                  Text(
                                    e.content.length > 100
                                        ? '${e.content.substring(0, 100)}…'
                                        : e.content,
                                    style: TextStyle(
                                        fontSize: 13,
                                        height: 1.5,
                                        color: isDark
                                            ? const Color(0xFFd1d5db)
                                            : const Color(0xFF374151)),
                                  ),
                                ]),
                          ),
                        ]),
                  ),
                ),
              )),
        ],
      ],
    );
  }

  void _showOptions(BuildContext ctx, JournalEntry e) {
    final p = ctx.read<LifeTrackProvider>();
    showModalBottomSheet(
      context: ctx,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(ctx);
              Navigator.push(ctx,
                  MaterialPageRoute(builder: (_) => AddJournalScreen(entry: e)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Color(0xFFef4444)),
            title:
                const Text('Delete', style: TextStyle(color: Color(0xFFef4444))),
            onTap: () {
              Navigator.pop(ctx);
              p.deleteJournalEntry(e.id);
            },
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Transactions tab
// ─────────────────────────────────────────────────────────────────────────────

class _TransactionsTab extends StatefulWidget {
  final bool isDark;
  const _TransactionsTab({required this.isDark});

  @override
  State<_TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<_TransactionsTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  TransactionType? _filter;

  static final _fmt = NumberFormat.currency(symbol: '\$');

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = context.watch<LifeTrackProvider>().transactions.where((t) {
      if (_filter != null && t.type != _filter) return false;
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        return t.note.toLowerCase().contains(q) ||
            t.category.label.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    final groups = <String, List<Transaction>>{};
    for (final t in all) {
      final key = DateFormat('MMMM yyyy').format(t.date);
      (groups[key] ??= []).add(t);
    }

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Column(children: [
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search transactions…',
              hintStyle: TextStyle(
                  fontSize: 13,
                  color: widget.isDark
                      ? const Color(0xFF4b5563)
                      : const Color(0xFF9ca3af)),
              prefixIcon: Icon(Icons.search_rounded,
                  color: widget.isDark
                      ? const Color(0xFF4b5563)
                      : const Color(0xFF9ca3af)),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: widget.isDark
                  ? const Color(0xFF1a1a2e)
                  : const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            _FilterChip(
                label: 'All',
                selected: _filter == null,
                isDark: widget.isDark,
                onTap: () => setState(() => _filter = null)),
            const SizedBox(width: 8),
            _FilterChip(
                label: 'Income',
                selected: _filter == TransactionType.income,
                isDark: widget.isDark,
                onTap: () => setState(() => _filter = TransactionType.income)),
            const SizedBox(width: 8),
            _FilterChip(
                label: 'Expenses',
                selected: _filter == TransactionType.expense,
                isDark: widget.isDark,
                onTap: () => setState(() => _filter = TransactionType.expense)),
          ]),
        ]),
      ),
      Expanded(
        child: all.isEmpty
            ? _Empty(
                emoji: '💳',
                message: 'No transactions found',
                isDark: widget.isDark)
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                children: [
                  for (final entry in groups.entries) ...[
                    _MonthHeader(
                        month: entry.key,
                        txns: entry.value,
                        isDark: widget.isDark,
                        fmt: _fmt),
                    const SizedBox(height: 8),
                    ...entry.value.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _TxnTile(
                            txn: t,
                            isDark: widget.isDark,
                            fmt: _fmt,
                            onEdit: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        AddTransactionScreen(transaction: t))),
                            onDelete: () => context
                                .read<LifeTrackProvider>()
                                .deleteTransaction(t.id),
                          ),
                        )),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;
  const _Chip({required this.label, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500, color: color)),
      );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected, isDark;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label,
      required this.selected,
      required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF6366f1).withValues(alpha: 0.12)
                : isDark
                    ? const Color(0xFF1a1a2e)
                    : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? const Color(0xFF6366f1).withValues(alpha: 0.5)
                  : isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : const Color(0xFFe5e7eb),
            ),
          ),
          child: Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected
                    ? const Color(0xFF6366f1)
                    : isDark
                        ? const Color(0xFF9ca3af)
                        : const Color(0xFF6b7280),
              )),
        ),
      );
}

class _MonthHeader extends StatelessWidget {
  final String month;
  final List<Transaction> txns;
  final bool isDark;
  final NumberFormat fmt;
  const _MonthHeader(
      {required this.month,
      required this.txns,
      required this.isDark,
      required this.fmt});

  @override
  Widget build(BuildContext context) {
    final income = txns
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final expenses = txns
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);

    return Row(children: [
      Text(month,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color:
                isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af),
          )),
      const Spacer(),
      Text('+${fmt.format(income)}',
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF10b981))),
      const SizedBox(width: 8),
      Text('-${fmt.format(expenses)}',
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFef4444))),
    ]);
  }
}

class _TxnTile extends StatelessWidget {
  final Transaction txn;
  final bool isDark;
  final NumberFormat fmt;
  final VoidCallback onEdit, onDelete;
  const _TxnTile(
      {required this.txn,
      required this.isDark,
      required this.fmt,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isIncome = txn.type == TransactionType.income;
    return GestureDetector(
      onLongPress: () => showModalBottomSheet(
        context: context,
        builder: (_) => SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                }),
            ListTile(
                leading: const Icon(Icons.delete_outline,
                    color: Color(0xFFef4444)),
                title: const Text('Delete',
                    style: TextStyle(color: Color(0xFFef4444))),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                }),
          ]),
        ),
      ),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color:
              isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : const Color(0xFFe5e7eb),
          ),
        ),
        child: Row(children: [
          Text(txn.category.emoji,
              style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      txn.note.isNotEmpty
                          ? txn.note
                          : txn.category.label,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111827))),
                  Text(
                      '${txn.category.label} · ${DateFormat('MMM d, yyyy').format(txn.date)}',
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? const Color(0xFF6b7280)
                              : const Color(0xFF9ca3af))),
                ]),
          ),
          Text(
            '${isIncome ? '+' : '-'}${fmt.format(txn.amount)}',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isIncome
                    ? const Color(0xFF10b981)
                    : const Color(0xFFef4444)),
          ),
        ]),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String emoji, message;
  final bool isDark;
  const _Empty(
      {required this.emoji, required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji,
              style: TextStyle(
                  fontSize: 36,
                  color: isDark
                      ? const Color(0xFF374151)
                      : const Color(0xFFd1d5db))),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFF4b5563)
                      : const Color(0xFF9ca3af))),
        ]),
      );
}

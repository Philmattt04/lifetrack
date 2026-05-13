import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/lifetrack_provider.dart';
import '../models/journal_entry.dart';
import '../models/transaction.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  static final _fmt = NumberFormat.currency(symbol: '\$');

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LifeTrackProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    if (p.loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6366f1)));
    }

    final hour = now.hour;
    final greeting = hour < 12 ? 'Good morning ☀️' : hour < 17 ? 'Good afternoon 🌤' : 'Good evening 🌙';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: [
          Text(greeting, style: TextStyle(fontSize: 13,
              color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af))),
          const SizedBox(height: 2),
          Text(DateFormat('EEEE, MMMM d').format(now),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111827))),
          const SizedBox(height: 24),

          // ── Habits card ──────────────────────────────────────
          _DashCard(
            emoji: '✅', title: 'Habits',
            subtitle: '${p.todayCompleted} / ${p.todayHabits.length} today',
            isDark: isDark,
            child: Column(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: p.todayHabitRate,
                  minHeight: 6,
                  backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFe5e7eb),
                  valueColor: AlwaysStoppedAnimation(
                    p.todayHabitRate == 1.0 ? const Color(0xFF22c55e) : const Color(0xFF6366f1),
                  ),
                ),
              ),
              if (p.todayHabits.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...p.todayHabits.take(3).map((h) {
                  final done = p.todayCompletions[h.id] ?? false;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(children: [
                      Text(h.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(h.name, style: TextStyle(
                        fontSize: 13,
                        color: done
                            ? (isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af))
                            : (isDark ? Colors.white : const Color(0xFF111827)),
                        decoration: done ? TextDecoration.lineThrough : null,
                      ))),
                      Icon(
                        done ? Icons.check_circle_rounded : Icons.circle_outlined,
                        size: 18,
                        color: done ? const Color(0xFF22c55e)
                            : isDark ? const Color(0xFF374151) : const Color(0xFFd1d5db),
                      ),
                    ]),
                  );
                }),
                if (p.todayHabits.length > 3)
                  Text('+${p.todayHabits.length - 3} more',
                      style: TextStyle(fontSize: 11,
                          color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af))),
              ],
            ]),
          ),
          const SizedBox(height: 12),

          // ── Mood card ────────────────────────────────────────
          _DashCard(
            emoji: '📔', title: 'Journal & Mood',
            subtitle: p.todayEntry == null ? 'No entry today' : JournalEntry.moodLabel(p.todayEntry!.mood),
            isDark: isDark,
            child: p.todayEntry == null
                ? Text('Tap + to write today\'s entry', style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af)))
                : Row(children: [
                    Text(JournalEntry.moodEmoji(p.todayEntry!.mood),
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(
                      p.todayEntry!.content.length > 80
                          ? '${p.todayEntry!.content.substring(0, 80)}…'
                          : p.todayEntry!.content,
                      style: TextStyle(fontSize: 13, height: 1.5,
                          color: isDark ? const Color(0xFFd1d5db) : const Color(0xFF374151)),
                    )),
                  ]),
          ),
          const SizedBox(height: 12),

          // ── Budget card ──────────────────────────────────────
          _DashCard(
            emoji: '💸', title: 'Budget',
            subtitle: DateFormat('MMMM').format(now),
            isDark: isDark,
            child: Row(children: [
              Expanded(child: _MiniStat(
                label: 'Income',
                value: _fmt.format(p.monthIncome),
                color: const Color(0xFF10b981),
                isDark: isDark,
              )),
              Expanded(child: _MiniStat(
                label: 'Spent',
                value: _fmt.format(p.monthExpenses),
                color: const Color(0xFFef4444),
                isDark: isDark,
              )),
              Expanded(child: _MiniStat(
                label: 'Balance',
                value: _fmt.format(p.monthBalance),
                color: p.monthBalance >= 0 ? const Color(0xFF10b981) : const Color(0xFFef4444),
                isDark: isDark,
              )),
            ]),
          ),
          const SizedBox(height: 24),

          // ── Recent transactions ──────────────────────────────
          if (p.thisMonthTransactions.isNotEmpty) ...[
            _SectionLabel(label: 'RECENT ACTIVITY', isDark: isDark),
            const SizedBox(height: 10),
            ...p.thisMonthTransactions.take(3).map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TxnRow(txn: t, isDark: isDark, fmt: _fmt),
            )),
          ],
        ],
      ),
    );
  }
}

class _DashCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final bool isDark;
  final Widget child;
  const _DashCard({required this.emoji, required this.title,
      required this.subtitle, required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFe5e7eb),
      ),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF111827))),
        const Spacer(),
        Text(subtitle, style: TextStyle(fontSize: 12,
            color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af))),
      ]),
      const SizedBox(height: 12),
      child,
    ]),
  );
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool isDark;
  const _MiniStat({required this.label, required this.value,
      required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
    const SizedBox(height: 2),
    Text(label, style: TextStyle(fontSize: 10,
        color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af))),
  ]);
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) => Text(label, style: TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8,
    color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af),
  ));
}

class _TxnRow extends StatelessWidget {
  final Transaction txn;
  final bool isDark;
  final NumberFormat fmt;
  const _TxnRow({required this.txn, required this.isDark, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final isIncome = txn.type == TransactionType.income;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFe5e7eb),
        ),
      ),
      child: Row(children: [
        Text(txn.category.emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(child: Text(
          txn.note.isNotEmpty ? txn.note : txn.category.label,
          style: TextStyle(fontSize: 13,
              color: isDark ? Colors.white : const Color(0xFF111827)),
        )),
        Text(
          '${isIncome ? '+' : '-'}${fmt.format(txn.amount)}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: isIncome ? const Color(0xFF10b981) : const Color(0xFFef4444)),
        ),
      ]),
    );
  }
}

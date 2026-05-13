import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/lifetrack_provider.dart';
import '../models/habit.dart';
import 'add_habit_screen.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LifeTrackProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Habits', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF111827))),
                const SizedBox(height: 4),
                Text(DateFormat('EEEE, MMMM d').format(now),
                    style: TextStyle(fontSize: 12,
                        color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af))),
                const SizedBox(height: 20),
                if (p.todayHabits.isNotEmpty) ...[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('${p.todayCompleted} / ${p.todayHabits.length} completed',
                        style: TextStyle(fontSize: 13,
                            color: isDark ? const Color(0xFF9ca3af) : const Color(0xFF6b7280))),
                    Text('${(p.todayHabitRate * 100).round()}%',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                            color: Color(0xFF22c55e))),
                  ]),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: p.todayHabitRate, minHeight: 6,
                      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFe5e7eb),
                      valueColor: AlwaysStoppedAnimation(
                        p.todayHabitRate == 1.0 ? const Color(0xFF22c55e) : const Color(0xFF6366f1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Text("TODAY'S HABITS", style: TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w600, letterSpacing: 0.8,
                    color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af))),
                const SizedBox(height: 10),
              ]),
            ),
          ),
          if (p.todayHabits.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(child: Column(children: [
                  Text('✅', style: TextStyle(fontSize: 36,
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFd1d5db))),
                  const SizedBox(height: 12),
                  Text('No habits yet', style: TextStyle(fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF4b5563) : const Color(0xFF9ca3af))),
                  const SizedBox(height: 4),
                  Text('Tap + to add your first habit', style: TextStyle(fontSize: 12,
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFd1d5db))),
                ])),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: p.todayHabits.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final h = p.todayHabits[i];
                  final done = p.todayCompletions[h.id] ?? false;
                  return _HabitTile(
                    habit: h, done: done, isDark: isDark,
                    onTap: () => p.toggleHabit(h.id),
                    onLongPress: () => _showOptions(ctx, h, p),
                  );
                },
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  void _showOptions(BuildContext ctx, Habit h, LifeTrackProvider p) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: const Text('Edit'),
          onTap: () {
            Navigator.pop(ctx);
            Navigator.push(ctx, MaterialPageRoute(builder: (_) => AddHabitScreen(habit: h)));
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline, color: Color(0xFFef4444)),
          title: const Text('Delete', style: TextStyle(color: Color(0xFFef4444))),
          onTap: () { Navigator.pop(ctx); p.deleteHabit(h.id); },
        ),
      ])),
    );
  }
}

class _HabitTile extends StatelessWidget {
  final Habit habit;
  final bool done, isDark;
  final VoidCallback onTap, onLongPress;
  const _HabitTile({required this.habit, required this.done, required this.isDark,
      required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap, onLongPress: onLongPress,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: done
            ? habit.color.withValues(alpha: isDark ? 0.15 : 0.08)
            : isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: done
              ? habit.color.withValues(alpha: isDark ? 0.4 : 0.3)
              : isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFe5e7eb),
        ),
      ),
      child: Row(children: [
        Text(habit.emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 14),
        Expanded(child: Text(habit.name, style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500,
          color: done
              ? (isDark ? const Color(0xFF9ca3af) : const Color(0xFF6b7280))
              : (isDark ? Colors.white : const Color(0xFF111827)),
          decoration: done ? TextDecoration.lineThrough : null,
        ))),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: done ? habit.color : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: done ? habit.color
                  : isDark ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFd1d5db),
              width: 2,
            ),
          ),
          child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
        ),
      ]),
    ),
  );
}

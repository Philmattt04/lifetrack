import 'package:flutter/material.dart';
import 'habits_screen.dart';
import 'journal_screen.dart';
import 'budget_screen.dart';
import 'add_habit_screen.dart';
import 'add_journal_screen.dart';
import 'add_transaction_screen.dart';

class LifestylesScreen extends StatefulWidget {
  const LifestylesScreen({super.key});

  @override
  State<LifestylesScreen> createState() => _LifestylesScreenState();
}

class _LifestylesScreenState extends State<LifestylesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) setState(() => _tabIndex = _tab.index);
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Widget _fab() {
    switch (_tabIndex) {
      case 0:
        return FloatingActionButton(
          heroTag: 'lifestyles_fab',
          backgroundColor: const Color(0xFF6366f1),
          foregroundColor: Colors.white,
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddHabitScreen())),
          child: const Icon(Icons.add_rounded),
        );
      case 1:
        return FloatingActionButton(
          heroTag: 'lifestyles_fab',
          backgroundColor: const Color(0xFFf59e0b),
          foregroundColor: Colors.white,
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddJournalScreen())),
          child: const Icon(Icons.edit_rounded),
        );
      default:
        return FloatingActionButton(
          heroTag: 'lifestyles_fab',
          backgroundColor: const Color(0xFF10b981),
          foregroundColor: Colors.white,
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
          child: const Icon(Icons.add_rounded),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: _fab(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Text(
                'Lifestyles',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TabBar(
              controller: _tab,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              labelColor: isDark ? Colors.white : const Color(0xFF111827),
              unselectedLabelColor:
                  isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af),
              labelStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              indicatorColor: _tabColors[_tabIndex],
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : const Color(0xFFe5e7eb),
              tabs: const [
                Tab(text: 'Habits'),
                Tab(text: 'Journal'),
                Tab(text: 'Budget'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: const [
                  HabitsScreen(),
                  JournalScreen(),
                  BudgetScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _tabColors = [
    Color(0xFF22c55e),
    Color(0xFFf59e0b),
    Color(0xFF10b981),
  ];
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/lifetrack_provider.dart';
import 'screens/today_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/add_habit_screen.dart';
import 'screens/add_journal_screen.dart';
import 'screens/add_transaction_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LifeTrackProvider()..load(),
      child: const LifeTrackApp(),
    ),
  );
}

class LifeTrackApp extends StatelessWidget {
  const LifeTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeTrack',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const _Shell(),
    );
  }

  ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? const Color(0xFF0f0f0f) : Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366f1),
        brightness: brightness,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF0f0f0f) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF111827),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      useMaterial3: true,
    );
  }
}

class _Shell extends StatefulWidget {
  const _Shell();

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _index = 0;

  static const _screens = [
    TodayScreen(),
    HabitsScreen(),
    JournalScreen(),
    BudgetScreen(),
    InsightsScreen(),
  ];

  Widget? _fab(BuildContext context) {
    switch (_index) {
      case 1:
        return FloatingActionButton(
          backgroundColor: const Color(0xFF6366f1),
          foregroundColor: Colors.white,
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddHabitScreen())),
          child: const Icon(Icons.add_rounded),
        );
      case 2:
        return FloatingActionButton(
          backgroundColor: const Color(0xFFf59e0b),
          foregroundColor: Colors.white,
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddJournalScreen())),
          child: const Icon(Icons.edit_rounded),
        );
      case 3:
        return FloatingActionButton(
          backgroundColor: const Color(0xFF10b981),
          foregroundColor: Colors.white,
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
          child: const Icon(Icons.add_rounded),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: _fab(context),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: isDark ? const Color(0xFF0f0f0f) : Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFF6366f1).withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF6366f1)),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline_rounded),
            selectedIcon: Icon(Icons.check_circle_rounded, color: Color(0xFF22c55e)),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded, color: Color(0xFFf59e0b)),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF10b981)),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome_rounded, color: Color(0xFF6366f1)),
            label: 'Insights',
          ),
        ],
      ),
    );
  }
}

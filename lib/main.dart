import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/lifetrack_provider.dart';
import 'screens/today_screen.dart';
import 'screens/lifestyles_screen.dart';
import 'screens/all_data_screen.dart';
import 'screens/insights_screen.dart';

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
    LifestylesScreen(),
    AllDataScreen(),
    InsightsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
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
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa_rounded, color: Color(0xFF6366f1)),
            label: 'Lifestyles',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt_rounded, color: Color(0xFF6366f1)),
            label: 'All Data',
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

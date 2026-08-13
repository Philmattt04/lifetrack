import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/lifetrack_provider.dart';
import 'screens/today_screen.dart';
import 'screens/lifestyles_screen.dart';
import 'screens/all_data_screen.dart';
import 'screens/insights_screen.dart';

const _themeModePrefKey = 'lt_theme_mode';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LifeTrackProvider()..load(),
      child: const LifeTrackApp(),
    ),
  );
}

class ThemeModeController extends ValueNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeModePrefKey);
    if (saved == 'light') value = ThemeMode.light;
    if (saved == 'dark') value = ThemeMode.dark;
  }

  Future<void> toggle() async {
    value = value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModePrefKey, value == ThemeMode.dark ? 'dark' : 'light');
  }
}

class LifeTrackApp extends StatefulWidget {
  const LifeTrackApp({super.key});

  @override
  State<LifeTrackApp> createState() => _LifeTrackAppState();
}

class _LifeTrackAppState extends State<LifeTrackApp> {
  final _themeMode = ThemeModeController();

  @override
  void dispose() {
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'LifeTrack',
          debugShowCheckedModeBanner: false,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          themeMode: mode,
          home: _Shell(themeMode: _themeMode),
        );
      },
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
  final ThemeModeController themeMode;

  const _Shell({required this.themeMode});

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
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: IndexedStack(index: _index, children: _screens),
          ),
          Positioned(
            top: 8,
            right: 12,
            child: SafeArea(
              bottom: false,
              child: _ThemeToggleButton(
                isDark: isDark,
                onPressed: widget.themeMode.toggle,
              ),
            ),
          ),
        ],
      ),
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

class _ThemeToggleButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onPressed;

  const _ThemeToggleButton({required this.isDark, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? const Color(0xFF1f1f1f) : const Color(0xFFf3f4f6),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
        icon: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: isDark ? Colors.white : const Color(0xFF111827),
          size: 20,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

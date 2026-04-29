import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'generator_screeen.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  // Which tab is currently selected — starts on Vault (index 0)
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),       // index 0 — Vault
    GeneratorScreen(),  // index 1 — Generator
    DashboardScreen(),  // index 2 — Dashboard
    SettingsScreen(),   // index 3 — Settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      // The bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          // If user taps Dashboard tab, tell it to refresh
          // (optional — comment out if not needed)
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1E3A5F),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle:
            const TextStyle(fontSize: 11),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_outlined),
            activeIcon: Icon(Icons.shield),
            label: 'Vault',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.casino_outlined),
            activeIcon: Icon(Icons.casino),
            label: 'Generator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
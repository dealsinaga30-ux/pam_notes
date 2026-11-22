import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'campus_map.dart';
import 'notes_screen.dart';
import 'weather_screen.dart';
import '../services/auth_service.dart';
import '../widgets/banner_ad_widget.dart';

class HomeShell extends StatefulWidget {
  final User user;
  final AuthService authService;

  const HomeShell({
    super.key,
    required this.user,
    required this.authService,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const NotesScreen(),
    const CampusMap(),
    WeatherScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.email ?? 'PAM Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () => widget.authService.signOut(),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdWidget(),
          NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.note), label: 'Catatan'),
              NavigationDestination(icon: Icon(Icons.map), label: 'Peta'),
              NavigationDestination(icon: Icon(Icons.cloud), label: 'Cuaca'),
            ],
          ),
        ],
      ),
    );
  }
}
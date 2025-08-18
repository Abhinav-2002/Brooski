import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Tabs (use your existing screens; these names match your project)
import 'package:brooski_app/features/home/screens/worker_home_screen.dart';
import 'package:brooski_app/features/chat/screens/chat_list_screen.dart';
import 'package:brooski_app/features/jobs/screens/my_jobs_screen.dart';
import 'package:brooski_app/features/worker/screens/worker_profile_screen.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key, this.initialIndex = 0});

  /// Which tab to show first: 0=Home, 1=Chat, 2=My Jobs, 3=Profile
  final int initialIndex;

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  static const _bg = Color(0xFFF7FAF7);
  static const _active = Color(0xFF2ECC71);

  late int _index;

  final _pages = const <Widget>[
    WorkerHomeScreen(),  
    ChatListScreen(),
    MyJobsScreen(),
    WorkerProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _index = (widget.initialIndex >= 0 && widget.initialIndex < _pages.length)
        ? widget.initialIndex
        : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: _bg,
        elevation: 0,
        indicatorColor: _active.withOpacity(0.15),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded, color: _active),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            selectedIcon: const Icon(Icons.chat_bubble, color: _active),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: const Icon(Icons.assignment, color: _active),
            label: 'My Jobs',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person, color: _active),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

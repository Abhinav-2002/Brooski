import 'package:brooski_app/features/chat/screens/chat_list_screen.dart';
import 'package:brooski_app/features/home/screens/worker_home_screen.dart';
import 'package:brooski_app/features/jobs/screens/my_jobs_screen.dart';
import 'package:brooski_app/features/profile/screens/worker_profile_screen.dart';
import 'package:flutter/material.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const WorkerHomeScreen(),
    const ChatListScreen(),
    const MyJobsScreen(),
    const WorkerProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    print("WorkerDashboardScreen has been loaded.");
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF2ECC71);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'My Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      // The SOS button will be handled separately, likely overlaid or in the AppBar
    );
  }
}

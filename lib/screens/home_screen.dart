import 'package:flutter/material.dart';
import 'timetable_screen.dart';
import 'todo_screen.dart';
import 'notes_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TimetableScreen(),
    const TodoScreen(),
    const NotesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_getTitle())),
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo[900], // darker indigo for contrast
        unselectedItemColor: Colors.grey[600], // darker grey for clarity
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        showUnselectedLabels: true,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Timetable',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'To‑Do',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 1:
        return 'To‑Do List';
      case 2:
        return 'My Notes';
      case 3:
        return 'Profile';
      default:
        return 'My Timetable';
    }
  }
}

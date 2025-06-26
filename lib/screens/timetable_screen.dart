import 'package:flutter/material.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Scaffold(
      appBar: AppBar(title: const Text('My Timetable')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Day headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  days.map((d) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 8),
            // Placeholder for timetable grid
            Expanded(
              child: Center(
                child: Text(
                  'Your timetable grid\nwill go here!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
